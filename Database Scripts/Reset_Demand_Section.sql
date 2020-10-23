UPDATE "Demand_03_Saturday_Saturday_Afternoon" AS o
	SET  "Done"=NULL,
    ncars=NULL, nlgvs=NULL, nmcls=NULL, nogvs=NULL, ntaxis=NULL, nminib=NULL, nbuses=NULL, nbikes=NULL, nogvs2=NULL, nspaces=NULL, nnotes=NULL,
    sref=NULL, sbays=NULL, sreason=NULL, scars=NULL, slgvs=NULL, smcls=NULL, sogvs=NULL, staxis=NULL, sbikes=NULL, sbuses=NULL, sogvs2=NULL, sminib=NULL, snotes=NULL,
    dcars=NULL, dlgvs=NULL, dmcls=NULL, dogvs=NULL, dtaxis=NULL, dbikes=NULL, dbuses=NULL, dogvs2=NULL, dminib=NULL,
    "Photos_01"=NULL, "Photos_02"=NULL, "Photos_03"=NULL
	WHERE o."Section"= '4' AND o."Area"='1'
	AND o."Done" = 'true'