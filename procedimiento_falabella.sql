--Declaracion de variables
DECLARE  @corr varchar(9)
        ,@id int =0
        ,@id_registro int
        ,@NRO_LOCAL varchar(13)
    	,@FECHA_EMISION_OC varchar(8)
		,@FECHA_HASTA varchar(8)
		,@UPC varchar(14)
        ,@UNIDADES float
        ,@NRO_F12 varchar(17)
		,@NRO_OC varchar(17)
        ,@NOM_RECEPTOR varchar(70)
        ,@TELEFONO_COMPRADOR varchar(15)
		,@TELEFONO_RECEPTOR varchar(15)
        ,@DIRECCION_RECEPTOR varchar(100)
		,@codigo_poblacion varchar(8)
        ,@PRECIO_COSTO float
		,@OBSERVACION varchar(999)
        ,@nom_depto varchar(60)
		,@cod_dane varchar(2)
        ,@CIUDAD_RECEPTOR varchar(60)
        ,@IDENTIFICACION_CLIENTE varchar(20)
		,@FECHA_DESPACHO_PACTADA varchar(8)
		,@EMAIL varchar(20)
		,@resultado int
		,@cod_ciud nvarchar(5)
		,@nom_ciud nvarchar(30)
		,@cod_depto char(2)
		,@indicativo char(2)
		,@resultado1 nvarchar(200)
		,@pos int
		,@posfin int
		,@posini int
		
		
--seleccion de tabla consecutivos de corrida

select @corr=t_uico_c+1 
from erpln104c.dbo.tspint000512

select @corr [corrida]
 
--actualizacion ultima corrida
update	erpln104c.dbo.tspint000512 
	set		t_uico_c = @corr


--declaracion de cursor
DECLARE plano_falabella CURSOR FOR

--consulta tabla plano_exito

select top (5)	 @corr [corrida],
		pla.[id_registro][id_registro],
		'FALLB'+pla.[NRO_LOCAL] [EAN ENTREGA],
		'FALLB'+pla.[NRO_LOCAL] [EAN FACTURA],
	    convert(varchar(8),convert(datetime,pla.[FECHA_EMISION_OC]),112)[Fecha minima entrega],
		convert(varchar(8),convert(datetime,pla.[FECHA_HASTA]),112)[Fecha máxima entrega],
		pla.[UPC][EAN Artículo],
		CAST(pla.[UNIDADES] AS float)[Cantidad pedida],
		pla.[NRO_F12][Nro. OC],
		pla.[NOM_RECEPTOR][Nombre Cliente],
		pla.[TELEFONO_COMPRADOR][Teléfono 1],
		pla.[TELEFONO_RECEPTOR][Teléfono 2],
		pla.[DIRECCION_RECEPTOR][Dirección],
		''[Código población],
		pla.[NRO_OC][Remisión],
		CAST(pla.[PRECIO_COSTO] AS float) [Precio Neto],
		pla.[ OBSERVACION][Observaciones],
		pla.[CIUDAD_RECEPTOR][Nombre Poblacion de entrega de mercancia],
		REPLACE(LTRIM(RTRIM(pla.DNI_COMPRADOR)),'-','')[Numero de Cedula de cliente final],
		--pla.[IDENTIFICACION_CLIENTE][Numero de Cedula de cliente final],
		convert(varchar,convert(datetime,pla.[FECHA_DESPACHO_PACTADA]),112)[Fecha Promesa de entrega],
	    convert(varchar,convert(datetime,pla.[FECHA_EMISION_OC]),112)[Fecha Emision Orden Compra]
	
		 
		
FROM plano_falabella pla
left join detalle_plano_falabella detpla on detpla.id_registro_plano=pla.[id_registro]


where  detpla.estado is null 
--and detpla.estado!=1
order by id_registro DESC  



--apertura de cursor
open plano_falabella
FETCH NEXT FROM plano_falabella INTO @corr
									,@id_registro
									,@NRO_LOCAL
									,@NRO_LOCAL
									,@FECHA_EMISION_OC
									,@FECHA_HASTA 
									,@UPC 
									,@UNIDADES 
									,@NRO_F12 
									,@NOM_RECEPTOR
									,@TELEFONO_COMPRADOR
									,@TELEFONO_RECEPTOR
									,@DIRECCION_RECEPTOR
									,@codigo_poblacion 
									,@NRO_OC
									,@PRECIO_COSTO
									,@OBSERVACION
									,@CIUDAD_RECEPTOR 
									,@IDENTIFICACION_CLIENTE
									,@FECHA_DESPACHO_PACTADA 
								    ,@FECHA_EMISION_OC
							
	WHILE @@FETCH_STATUS = 0
	
	BEGIN

	SELECT @cod_ciud = '',@nom_ciud = '',@cod_depto = '',@nom_depto = '',@indicativo = ''
				--buscar datos de ciudad, departamento e indicativo en divipola
				SELECT @resultado1 = erpln104c.dspring.fn_busca_ciud_depto_ind(@CIUDAD_RECEPTOR)
				
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

	BEGIN
	

	

	--evalua si registro existe en tabla de detalle_plano_exito
	
	IF  EXISTS(SELECT * FROM detalle_plano_falabella where id_registro_plano=@id_registro)
	
	begin
	set @resultado=1
	END
	ELSE 
	begin
	

	--Evaluacion de insercion de registros
	begin try
	--incremental de registros en corrida
	set @id=@id+1
	
	--insercion en tabla spint110
	insert into erpln104c.dbo.tspint110512 values(   @corr
													,@id
													,'ASS'
													,@NRO_LOCAL
													,@NRO_LOCAL
													,'220'
													,@FECHA_EMISION_OC
													,@FECHA_HASTA
													,@UPC
													,@UNIDADES
													,@NRO_F12
													,'NE'
													,@NOM_RECEPTOR
													,@TELEFONO_COMPRADOR
													,@TELEFONO_RECEPTOR
													,@DIRECCION_RECEPTOR
													,@codigo_poblacion
													,@NRO_OC
													,''
													,0
													,@PRECIO_COSTO
													,0,0,0,0,0,0,0,0,0,0,0,0,0
													,'EDI'
													,dateadd(hh,-5,getdate())
													,0
													,0
													,''
													,@cod_depto
													,@IDENTIFICACION_CLIENTE
													,''
													,''
													,''
													,@FECHA_DESPACHO_PACTADA
													,@FECHA_EMISION_OC
													,''
													,''
													,@nom_depto
													,@nom_ciud
													,@OBSERVACION
													) 
	
	--insercion de registro procesado correctamente
	insert into detalle_plano_falabella values(@corr,@id,@id_registro,1,GETDATE(),'')

	end try
	begin catch

	--insercion de registros con error
	insert into detalle_plano_falabella values('','',@id_registro,3,GETDATE(),ERROR_MESSAGE())
	--disminucion de registros en corrida

	set @id=@id-1

	end catch

	select                                           @corr
													,@id
													,'ASS'
													,@NRO_LOCAL
													,@NRO_LOCAL
													,'220'
													,@FECHA_EMISION_OC
													,@FECHA_HASTA
													,@UPC
													,@UNIDADES
													,@NRO_F12
													,'NE'
													,@NOM_RECEPTOR
													,@TELEFONO_COMPRADOR
													,@TELEFONO_RECEPTOR
													,@DIRECCION_RECEPTOR
													,@codigo_poblacion
													,@NRO_OC
													,''
													,0
													,@PRECIO_COSTO
													,0,0,0,0,0,0,0,0,0,0,0,0,0
													,'EDI'
													,dateadd(hh,-5,getdate())
													,0
													,0
													,''
													,@cod_depto
													,@IDENTIFICACION_CLIENTE
													,''
													,''
													,''
													,@FECHA_DESPACHO_PACTADA
													,@FECHA_EMISION_OC
													,''
													,''
													,@nom_depto
													,@nom_ciud
													,@OBSERVACION
	END	

FETCH NEXT FROM plano_falabella INTO @corr
									,@id_registro
									,@NRO_LOCAL
									,@NRO_LOCAL
									,@FECHA_EMISION_OC
									,@FECHA_HASTA
									,@UPC
									,@UNIDADES
									,@NRO_F12
									,@NOM_RECEPTOR
									,@TELEFONO_RECEPTOR
									,@TELEFONO_RECEPTOR
									,@DIRECCION_RECEPTOR
									,@codigo_poblacion 
									,@NRO_OC
									,@PRECIO_COSTO
									,@OBSERVACION
									,@CIUDAD_RECEPTOR 
									,@IDENTIFICACION_CLIENTE
									,@FECHA_DESPACHO_PACTADA
									,@FECHA_EMISION_OC
								

	end

END

CLOSE plano_falabella
	DEALLOCATE plano_falabella
--generacion cabecera corrida lur
	insert erpln104c.dbo.tspint500512

	values (@corr,DATEADD(HH,-5,GETDATE()),'ASS',1,1,1,'EDI',DATEADD(HH,-5,GETDATE()),0,0)
