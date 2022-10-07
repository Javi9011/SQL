BEGIN TRAN
DECLARE
         @corr int
		,@id int
		,@ordenspint varchar(17)
		,@Orden_de_Compra varchar(17)
		,@Cliente varchar(20)
        ,@Nombre_envío varchar(70)
		,@Direc_envío varchar(100)
        ,@Ciudad varchar(100)
		,@resultado int
		,@cod_ciud nvarchar(5)
		,@nom_ciud nvarchar(30)
		,@nom_depto varchar (15)
		,@cod_depto char(2)
		,@indicativo char(2)
		,@resultado1 nvarchar(200)
		,@pos int
		,@posfin int
		,@posini int
		,@N_Tel varchar(15)
		
		


--declaracion de cursor
DECLARE plano_alkosto CURSOR FOR
select distinct	 spint110.t_idco_c
				,spint110.t_idre_c
				,spint110.t_nroc_c
				,[Unidad_Venta]+[Orden_de_Compra]
			    ,[Cliente][Cedula Cliente]
                ,[Nombre_envío][Nombre Cliente]
                ,[Direc_envío][Direccion Cliente]
                ,[Ciudad][Ciudad]
				,[N_Tel][Telefono Cliente]
				
FROM   erpln104c.dbo.tspint110512 spint110
left join erpln104c.dbo.tspint500512 spint500 on spint110.t_idco_c=spint500.t_idco_c
left join plano_alkosto on spint110.t_nroc_c collate database_default =[Unidad_Venta]+[Orden_de_Compra]collate database_default
where spint500.t_esco_c='10' 
and spint110.t_nroc_c collate database_default =[Unidad_Venta]+[Orden_de_Compra]collate database_default

--apertura de cursor
open plano_alkosto
FETCH NEXT FROM plano_alkosto  INTO		 @corr
										,@id
										,@ordenspint
										,@Orden_de_Compra
										,@Cliente
										,@Nombre_envío
										,@Direc_envío
  										,@Ciudad
										,@N_Tel
									
							
	WHILE @@FETCH_STATUS = 0

	BEGIN

	SELECT @cod_ciud = '',@nom_ciud = '',@cod_depto = '',@nom_depto = '',@indicativo = ''
				--buscar datos de ciudad, departamento e indicativo en divipola
				SELECT @resultado1 = erpln104c.dspring.fn_busca_ciud_depto_ind(@Ciudad)
				
				--revisar el resultado de ciudades y departamentos
				IF SUBSTRING(@resultado1,1,2) = 'SI'
				BEGIN				 
					SELECT @posfin = 1,@posini = 0,@pos = 1
					WHILE @posfin > 0	--busca los datos de ciudad y departamento separados por '|'
					BEGIN
						SELECT	@posfin = CHARINDEX('|',@resultado1,@posini+1)
				
						IF @pos = 1
							SELECT @cod_ciud = LTRIM(RTRIM(SUBSTRING(@resultado1,4,@posfin-4)))
						IF @pos = 2
							SELECT @nom_ciud = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))
						IF @pos = 3
							SELECT @cod_depto = LTRIM(RTRIM(SUBSTRING(@resultadO1,@posini+1,@posfin-(@posini+1))))
						IF @pos = 4
							SELECT @nom_depto = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,@posfin-(@posini+1))))
						IF @pos = 5
							SELECT @indicativo = LTRIM(RTRIM(SUBSTRING(@resultado1,@posini+1,2)))
					
						SELECT @posini = @posfin,@pos = @pos+1
					END
			
	END


update erpln104c.dbo.tspint110512 set 
										

													t_cedu_c=@Cliente 
												   ,t_nama_c=@Nombre_envío 
	                                               ,t_namc_c=@Direc_envío
                                                   ,t_npob_c=@Ciudad
												   ,t_cdep_c=@cod_depto
												   ,t_ndep_c=@nom_depto
												   ,t_ccit_c=@cod_ciud
												   ,t_tel1_c=@N_Tel

where t_idco_c=@corr and t_idre_c=@id and t_nroc_c=@Orden_de_Compra


select * from erpln104c.dbo.tspint110512
where t_idco_c=@corr and t_idre_c=@id and t_nroc_c=@Orden_de_Compra

update erpln104c.dbo.tspint500512
SET t_esco_c=1
where t_idco_c=@corr

FETCH NEXT FROM plano_alkosto INTO       @corr
										,@id
										,@ordenspint
										,@Orden_de_Compra
										,@Cliente
										,@Nombre_envío
										,@Direc_envío
  										,@Ciudad
										,@N_Tel
	end



CLOSE plano_alkosto
	DEALLOCATE plano_alkosto



--rollback
--commit


