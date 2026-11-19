-- Migration 001: Inisialisasi tabel kos dan konfigurasi Row Level Security (RLS)
-- KosFinder v1 (PostgreSQL / Supabase)

-- 1. Buat Tabel Kos
CREATE TABLE IF NOT EXISTS public.kos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    address TEXT NOT NULL,
    price_per_month BIGINT NOT NULL CHECK (price_per_month >= 0),
    type TEXT NOT NULL CHECK (type IN ('putra', 'putri', 'campur')),
    facilities TEXT[] NOT NULL DEFAULT '{}',
    description TEXT NOT NULL,
    available_rooms INT NOT NULL CHECK (available_rooms >= 0),
    whatsapp_number TEXT NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. Aktifkan Row Level Security (RLS)
ALTER TABLE public.kos ENABLE ROW LEVEL SECURITY;

-- 3. Policy SELECT: Siapa saja (publik/anonim dan pemilik) boleh melihat data kos
CREATE POLICY "Public and owners can view kos"
ON public.kos
FOR SELECT
USING (true);

-- 4. Policy INSERT: Hanya pemilik kos terautentikasi yang dapat menambahkan data miliknya
CREATE POLICY "Authenticated owners can insert own kos"
ON public.kos
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = owner_id);

-- 5. Policy UPDATE: Hanya pemilik kos terkait yang dapat mengubah datanya sendiri
CREATE POLICY "Authenticated owners can update own kos"
ON public.kos
FOR UPDATE
TO authenticated
USING (auth.uid() = owner_id)
WITH CHECK (auth.uid() = owner_id);

-- 6. Policy DELETE: Hanya pemilik kos terkait yang dapat menghapus datanya sendiri
CREATE POLICY "Authenticated owners can delete own kos"
ON public.kos
FOR DELETE
TO authenticated
USING (auth.uid() = owner_id);

-- 7. Trigger Otomatis untuk memperbarui kolom updated_at saat data diubah
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS set_updated_at ON public.kos;
CREATE TRIGGER set_updated_at
BEFORE UPDATE ON public.kos
FOR EACH ROW
EXECUTE FUNCTION public.handle_updated_at();
