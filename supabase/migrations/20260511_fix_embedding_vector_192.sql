-- Migration: resize face_embeddings.embedding from vector(128) → vector(192)
-- The app uses MobileFaceNet which outputs 192-D L2-normalised embeddings.
-- Run this once on your Supabase project (SQL editor or CLI).

ALTER TABLE face_embeddings
  ALTER COLUMN embedding TYPE vector(192)
  USING embedding::text::vector(192);
