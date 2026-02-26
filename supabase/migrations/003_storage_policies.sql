-- StudiOff - Storage Policies for 'audio' bucket
-- Exécutez ce script après avoir créé le bucket 'audio'

-- Politique: Les utilisateurs peuvent lire leurs propres fichiers audio
-- Les fichiers sont stockés dans: {user_id}/...
CREATE POLICY "Users can read own audio files"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'audio' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Politique: Les utilisateurs peuvent uploader dans leur dossier
CREATE POLICY "Users can upload own audio files"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'audio' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Politique: Les utilisateurs peuvent supprimer leurs fichiers
CREATE POLICY "Users can delete own audio files"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'audio' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Politique: Service role peut tout faire (pour les Edge Functions)
-- Note: Le service role bypass déjà RLS, mais on l'ajoute pour clarté
CREATE POLICY "Service role full access"
ON storage.objects FOR ALL
USING (bucket_id = 'audio')
WITH CHECK (bucket_id = 'audio');

SELECT 'Storage policies created successfully!' as result;
