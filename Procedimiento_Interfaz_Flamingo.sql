BEGIN TRAN
DECLARE  @corr int
		,@id int,@resultado1 varchar(max),@pos int,@posfin int, @posini int,@orden varchar (17),
@nombre nvarchar(max),@telefono nvarchar(30),@nom_depto nvarchar(60),@direccion nvarchar(max),@municipio varchar(max),
@remision varchar(15),@aceptacion varchar(2),@info_acep varchar(max),@cedula varchar(30),@cod_ciudad varchar(15),
@fecha_promesa_entrega varchar(12),@barrio varchar(100),@cod_depto varchar(2)

DECLARE plano_flamingo CURSOR FOR

select  spint110.t_idco_c,spint110.t_idre_c,spint110.t_nroc_c,spint110.t_obse_c  from tspint110512 spint110
left join tspint111512 spint111 on spint111.t_eaen_c=spint110.t_eaen_c
left join ttccom100512 tccom100 on spint111.t_bpid_c=tccom100.t_bpid
left join tspint500512 spint500 on spint110.t_idco_c=spint500.t_idco_c
where  tccom100.t_nama LIKE '%FLAMINGO%'
--and spint500.t_esco_c='10'
--and spint110.t_idco_c='100000185'
open plano_flamingo
FETCH NEXT FROM plano_flamingo  INTO @corr,@id,@orden,@resultado1

WHILE @@FETCH_STATUS = 0

BEGIN				
					SELECT @posfin = 1,@posini = 0,@pos = 1
					WHILE @posfin > 0	--busca los datos de ciudad y departamento separados por '|'
					BEGIN
						SELECT	@posfin = CHARINDEX('-',@resultado1,@posini+1)
				
						IF @pos = 1
							SELECT @nombre = LTRIM(RTRIM(SUBSTRING(@resultado1,0,@posfin)))
						IF @pos = 2
							SELECT @telefono = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))
						IF @pos = 3
							SELECT @nom_depto = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))
						IF @pos = 4
							SELECT @direccion = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))
						IF @pos = 5
							SELECT @municipio = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))

						IF @pos = 6
							SELECT @remision = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))

						IF @pos = 7
							SELECT @aceptacion = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))
						IF @pos = 8
							SELECT @info_acep = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))
						
						IF @pos = 9
							SELECT @cedula = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))

						IF @pos = 10
							SELECT  @cod_ciudad = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))

						IF @pos = 11
						SELECT @fecha_promesa_entrega = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))

						IF @pos = 12
							SELECT @barrio = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,50)))

						SELECT @posini = @posfin,@pos = @pos+1
					END

					SELECT @cod_depto=SUBSTRING(@cod_ciudad,1,2)

UPDATE tspint110512
 set t_nama_c=@nombre,t_tel1_c=@telefono,t_ndep_c=@nom_depto,
 t_namc_c=@direccion,t_npob_c=@municipio,t_remi_c=@remision,t_cedu_c=@cedula,
 t_ccit_c=@cod_ciudad,t_fpen_c=@fecha_promesa_entrega,t_baen_c=@barrio,t_cdep_c=@cod_depto
where t_idco_c=@corr and t_idre_c=@id and t_nroc_c=@orden

SELECT @corr,@id,@orden,@nombre,@telefono,@nom_depto,@direccion,@municipio,@remision,@aceptacion,@info_acep,@cedula
		,@cod_ciudad,@fecha_promesa_entrega,@barrio,@resultado1,@cod_depto

select * from tspint110512
where t_idco_c=@corr and t_idre_c=@id and t_nroc_c=@orden



FETCH NEXT FROM plano_flamingo INTO   @corr,@id,@orden,@resultado1
	end



CLOSE plano_flamingo
	DEALLOCATE plano_flamingo


	--COMMIT
	--ROLLBACK


/*select *  from tspint110512 spint110
left join tspint111512 spint111 on spint111.t_eaen_c=spint110.t_eaen_c
left join ttccom100512 tccom100 on spint111.t_bpid_c=tccom100.t_bpid
left join tspint500512 spint500 on spint110.t_idco_c=spint500.t_idco_c
where  tccom100.t_nama LIKE '%FLAMINGO%'
and spint500.t_esco_c='10'*/
--and spint110.t_idco_c='100000185'