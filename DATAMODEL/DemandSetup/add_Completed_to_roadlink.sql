/***

Add Completed field to roadlink

***/

ALTER TABLE IF EXISTS highways_network."roadlink"
  ADD COLUMN IF NOT EXISTS "Completed" boolean;
