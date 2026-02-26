// Supabase Edge Function: stripe-webhook
// Handles Stripe webhook events for subscription management

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import Stripe from "https://esm.sh/stripe@14.14.0?target=deno";

serve(async (req) => {
  try {
    const stripeKey = Deno.env.get("STRIPE_SECRET_KEY")!;
    const webhookSecret = Deno.env.get("STRIPE_WEBHOOK_SECRET")!;
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

    const stripe = new Stripe(stripeKey, { apiVersion: "2023-10-16" });
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Verify webhook signature
    const body = await req.text();
    const signature = req.headers.get("stripe-signature")!;
    
    let event: Stripe.Event;
    try {
      event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
    } catch (err: unknown) {
      const message = err instanceof Error ? err.message : 'Unknown error';
      console.error("Webhook signature verification failed:", message);
      return new Response("Webhook signature verification failed", { status: 400 });
    }

    console.log("Received event:", event.type);

    // Handle different event types
    switch (event.type) {
      case "checkout.session.completed": {
        const session = event.data.object as Stripe.Checkout.Session;
        await handleCheckoutCompleted(supabase, stripe, session);
        break;
      }

      case "customer.subscription.updated": {
        const subscription = event.data.object as Stripe.Subscription;
        await handleSubscriptionUpdated(supabase, subscription);
        break;
      }

      case "customer.subscription.deleted": {
        const subscription = event.data.object as Stripe.Subscription;
        await handleSubscriptionDeleted(supabase, subscription);
        break;
      }

      case "invoice.payment_succeeded": {
        const invoice = event.data.object as Stripe.Invoice;
        await handlePaymentSucceeded(supabase, invoice);
        break;
      }

      case "invoice.payment_failed": {
        const invoice = event.data.object as Stripe.Invoice;
        await handlePaymentFailed(supabase, invoice);
        break;
      }

      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    return new Response(JSON.stringify({ received: true }), { status: 200 });

  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : 'Unknown error';
    console.error("Webhook error:", message);
    return new Response(`Webhook error: ${message}`, { status: 500 });
  }
});

async function handleCheckoutCompleted(
  supabase: any, 
  stripe: Stripe, 
  session: Stripe.Checkout.Session
) {
  const userId = session.metadata?.supabase_user_id;
  if (!userId) {
    console.error("No user ID in session metadata");
    return;
  }

  // Get subscription details
  const subscription = await stripe.subscriptions.retrieve(session.subscription as string);
  const priceId = subscription.items.data[0].price.id;

  // Determine plan and credits
  const planConfig: Record<string, { plan: string; minutes: number }> = {
    price_starter_monthly: { plan: "starter", minutes: 30 },
    price_pro_monthly: { plan: "pro", minutes: 120 },
  };

  const config = planConfig[priceId] || { plan: "starter", minutes: 30 };

  // Create or update subscription record
  await supabase.from("subscriptions").upsert({
    user_id: userId,
    stripe_customer_id: session.customer as string,
    stripe_subscription_id: subscription.id,
    plan: config.plan,
    status: "active",
    monthly_minutes: config.minutes,
    current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
    current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
    updated_at: new Date().toISOString(),
  }, {
    onConflict: "user_id",
  });

  // Update user profile with credits
  await supabase
    .from("profiles")
    .update({
      credits_remaining: config.minutes,
      credits_used_this_month: 0,
      subscription_id: subscription.id,
      subscription_status: "active",
      subscription_plan: config.plan,
      subscription_end_date: new Date(subscription.current_period_end * 1000).toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("id", userId);

  console.log(`Subscription created for user ${userId}: ${config.plan}`);
}

async function handleSubscriptionUpdated(supabase: any, subscription: Stripe.Subscription) {
  const userId = subscription.metadata?.supabase_user_id;
  if (!userId) return;

  const statusMap: Record<string, string> = {
    active: "active",
    past_due: "past_due",
    canceled: "canceled",
    trialing: "trialing",
    incomplete: "incomplete",
  };

  await supabase
    .from("subscriptions")
    .update({
      status: statusMap[subscription.status] || subscription.status,
      current_period_start: new Date(subscription.current_period_start * 1000).toISOString(),
      current_period_end: new Date(subscription.current_period_end * 1000).toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("stripe_subscription_id", subscription.id);

  await supabase
    .from("profiles")
    .update({
      subscription_status: statusMap[subscription.status] || subscription.status,
      subscription_end_date: new Date(subscription.current_period_end * 1000).toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("id", userId);
}

async function handleSubscriptionDeleted(supabase: any, subscription: Stripe.Subscription) {
  const userId = subscription.metadata?.supabase_user_id;
  if (!userId) return;

  await supabase
    .from("subscriptions")
    .update({
      status: "canceled",
      canceled_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    })
    .eq("stripe_subscription_id", subscription.id);

  await supabase
    .from("profiles")
    .update({
      subscription_status: "canceled",
      updated_at: new Date().toISOString(),
    })
    .eq("id", userId);
}

async function handlePaymentSucceeded(supabase: any, invoice: Stripe.Invoice) {
  if (!invoice.subscription) return;

  // Reset monthly credits on successful payment
  const { data: sub } = await supabase
    .from("subscriptions")
    .select("user_id, monthly_minutes")
    .eq("stripe_subscription_id", invoice.subscription)
    .single();

  if (sub) {
    await supabase
      .from("profiles")
      .update({
        credits_remaining: sub.monthly_minutes,
        credits_used_this_month: 0,
        updated_at: new Date().toISOString(),
      })
      .eq("id", sub.user_id);
  }
}

async function handlePaymentFailed(supabase: any, invoice: Stripe.Invoice) {
  if (!invoice.subscription) return;

  await supabase
    .from("subscriptions")
    .update({
      status: "past_due",
      updated_at: new Date().toISOString(),
    })
    .eq("stripe_subscription_id", invoice.subscription);
}
