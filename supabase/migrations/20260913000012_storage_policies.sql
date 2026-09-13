-- Migration: 20260913000012_storage_policies.sql
-- Description: Supabase Storage bucket and RLS policies enforcing identical role/mine boundaries on media files.
-- Path Convention: {mine_id}/{record_type}/{record_id}/{filename}

-- 1. Create Media Evidence Storage Bucket if not exists
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
    'koylanetra-media',
    'koylanetra-media',
    false, -- Private bucket: access strictly controlled via RLS
    26214400, -- 25 MB max file size
    ARRAY['image/jpeg', 'image/png', 'image/webp', 'application/pdf']
)
ON CONFLICT (id) DO NOTHING;

-- 2. Storage Objects RLS Policies (storage.objects is pre-enabled for RLS by Supabase)

-- 2a. Storage SELECT Policy: Enforce mine/region scope matching the first path segment (mine_id)
CREATE POLICY "Storage media read policy by role scope"
ON storage.objects FOR SELECT
TO authenticated
USING (
    bucket_id = 'koylanetra-media' AND (
        -- Mine Manager or Field Officer: mine_id in path matches user's mine scope
        ((is_mine_manager() OR is_field_officer()) AND 
         (storage.foldername(name))[1]::uuid = auth_scope_id())
        OR
        -- Regulator: mine_id in path belongs to a mine in user's DGMS region scope
        (is_regulator() AND EXISTS (
            SELECT 1 FROM public.mines m 
            WHERE m.id = (storage.foldername(name))[1]::uuid 
              AND m.dgms_region_id = auth_scope_id()
        ))
    )
);

-- 2b. Storage INSERT Policy: Field Officers and Mine Managers upload to their own mine directory
CREATE POLICY "Storage media insert policy by role scope"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
    bucket_id = 'koylanetra-media' AND
    (is_field_officer() OR is_mine_manager()) AND
    (storage.foldername(name))[1]::uuid = auth_scope_id()
);

-- 2c. Storage UPDATE & DELETE Policies: Restricted to owning Mine Managers
CREATE POLICY "Storage media delete policy by mine manager"
ON storage.objects FOR DELETE
TO authenticated
USING (
    bucket_id = 'koylanetra-media' AND
    is_mine_manager() AND
    (storage.foldername(name))[1]::uuid = auth_scope_id()
);
