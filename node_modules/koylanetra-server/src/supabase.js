import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';

dotenv.config();

const SUPABASE_URL = process.env.SUPABASE_URL || 'https://qjpymsgyvsocvoeagfka.supabase.co';
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFqcHltc2d5dnNvY3ZvZWFnZmthIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODY5NTc3NjksImV4cCI6MjEwMjUzMzc2OX0.EhmPbcXJRxgzP8gwNXY1dFc0nnxMq6X9WeF3x4D8XH8';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
