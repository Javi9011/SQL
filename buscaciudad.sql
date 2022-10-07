USE [erpln104c]
GO
/****** Object:  UserDefinedFunction [dspring].[fn_busca_ciud_depto_ind]    Script Date: 07/10/2022 14:31:51 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER FUNCTION [dspring].[fn_busca_ciud_depto_ind](@cadena nvarchar(max))
	RETURNS nvarchar(200)
AS
BEGIN	
	DECLARE @pos int,@posini int = 0,@posfin int = 1,@cadena_enc nvarchar(15),@cadena_aux nvarchar(max)
			,@cant_reg int,@cant_reg_ciu int,@cant_reg_dep int,@continuar int = 1
			,@resultado nvarchar(200),@donde varchar(80)

	DECLARE @datos_enc
		TABLE	([Cod_ciud] varchar(5)
				 ,[Nom_ciud] varchar(60)
				 ,[Cod_depto] varchar(2)
				 ,[Nom_depto] varchar(60)
				 ,[Indicativo] varchar(2)
				 )  --tabla temporal para manejo de departamentos y ciudades 
				 
	DECLARE @datos_enc_depto
		TABLE	([Cod_depto] varchar(2)
				 )  --tabla temporal para manejo de departamentos encontrados
				 
	DECLARE @datos_enc_ciud
		TABLE	([Cod_ciud] varchar(5)
				 )  --tabla temporal para manejo de ciudades encontrados

	--reemplazando caracteres diferentes a espacio y '-' y letras por '-'
	SELECT @pos = PATINDEX('%[^ A-Z-]%',@cadena COLLATE Latin1_General_CI_AI)
	WHILE @pos <> 0
	BEGIN
		SELECT @cadena = REPLACE(@cadena,SUBSTRING(@cadena,@pos,1),'-')
		SELECT @pos = PATINDEX('%[^ A-Z-]%',@cadena COLLATE Latin1_General_CI_AI)	
	END
	SELECT @cadena_aux = @cadena
	
	WHILE @continuar = 1
	BEGIN
		--Busqueda de datos desde la cadena
		--busqueda por nombre igual a la ciudad en tabla de nemotecnia
		INSERT	INTO @datos_enc_ciud 
			SELECT	DISTINCT t_city_c	--codigo ciudad
			FROM	tspspg804512 with (nolock)
			WHERE	t_dsca_c COLLATE Latin1_General_CI_AI = LTRIM(RTRIM(UPPER(@cadena))) --el nombre de la ciudad es igual al enviado

		SELECT @cant_reg_ciu = COUNT(*) FROM @datos_enc_ciud  --cantidad de ciudades encontradas
		
		IF @cant_reg_ciu = 1 --Se encuentra ciudad
		BEGIN
			INSERT	INTO @datos_enc 
				SELECT	DISTINCT t_city_c	--codigo ciudad
						,t_dsca_c	--nombre ciudad
						,t_cste_c	--codigo departamento
						,t_dsdp_c	--nombre departamento
						,t_idco_c	--indicativo
				FROM	tspspg804512 with (nolock)
				WHERE	t_city_c = (SELECT Cod_ciud FROM @datos_enc_ciud)
			BREAK --sale del ciclo termina busqueda
		END		
		--Borra registros de tablas temporales
		DELETE FROM @datos_enc_ciud 
		DELETE @datos_enc_depto
		--fin por nombre
		
		--inicia busqueda por palabras de la cadena separadas por '-'
		--separar cadenas utilizando el '-' como delimitador
		WHILE @posfin > 0	--busca los textos entre "-" de la cadena enviada
		BEGIN
			SELECT	@posfin = CHARINDEX ('-',@cadena,@posini+1)

			IF @posfin <> 0	--encontro un "-" finalizando un texto
				SELECT	@cadena_enc = SUBSTRING(@cadena,@posini+1,@posfin-(@posini+1))
			ELSE	--no encontro un "-" finalizando una palabra
				SELECT	@cadena_enc = SUBSTRING(@cadena,@posini+1,LEN(@cadena)-(@posini))	
			
			--busca la cadena encontrada
			IF LEN(@cadena_enc) > 2 --Controla que sea mas de dos caracteres 
			BEGIN
				--buscar departamento
				SELECT @cant_reg = COUNT(*) FROM tspspg804512 with (nolock)
								WHERE	CHARINDEX(LTRIM(RTRIM(@cadena_enc)),t_dsdp_c COLLATE Latin1_General_CI_AI) <> 0
										AND t_cste_c <> '11'
				IF @cant_reg > 0
					INSERT	INTO @datos_enc_depto 
						SELECT	DISTINCT t_cste_c	--codigo departamento
						FROM	tspspg804512 with (nolock)
						WHERE	CHARINDEX(LTRIM(RTRIM(@cadena_enc)),t_dsdp_c COLLATE Latin1_General_CI_AI) <> 0
					
				--buscar ciudad
				IF @cant_reg = 0
					INSERT	INTO @datos_enc_ciud 
						SELECT	DISTINCT t_city_c	--codigo ciudad
						FROM	tspspg804512 with (nolock)
						WHERE	CHARINDEX(LTRIM(RTRIM(@cadena_enc)),t_dsca_c COLLATE Latin1_General_CI_AI) <> 0
			END			
			SET @posini = @posfin
		END
		
		--Validacion de resultados
		SELECT @cant_reg_ciu = COUNT(*) FROM @datos_enc_ciud  --cantidad de ciudades encontradas
		SELECT @cant_reg_dep = COUNT(*) FROM @datos_enc_depto  --cantidad de departamentos encontrados	
		SELECT @cant_reg = 0   
		
		IF @cant_reg_ciu = 1 --Se encuentra ciudad
		BEGIN
			INSERT	INTO @datos_enc 
				SELECT	DISTINCT t_city_c	--codigo ciudad
						,t_dsca_c	--nombre ciudad
						,t_cste_c	--codigo departamento
						,t_dsdp_c	--nombre departamento
						,t_idco_c	--indicativo
				FROM	tspspg804512 with (nolock)
				WHERE	t_city_c = (SELECT Cod_ciud FROM @datos_enc_ciud)
			BREAK --sale del ciclo termina busqueda
		END
		
		IF @cant_reg_ciu > 1 AND @cant_reg_dep = 1 --mas de una ciudad encontrada un solo departamento
		BEGIN
			SELECT @cant_reg = COUNT(*) FROM @datos_enc_ciud WHERE LEFT(Cod_ciud,2) = (SELECT Cod_depto FROM @datos_enc_depto)
			IF @cant_reg = 1
			BEGIN
				INSERT	INTO @datos_enc 
					SELECT	DISTINCT t_city_c	--codigo ciudad
							,t_dsca_c	--nombre ciudad
							,t_cste_c	--codigo departamento
							,t_dsdp_c	--nombre departamento
							,t_idco_c	--indicativo
					FROM	tspspg804512 with (nolock)
					WHERE	t_city_c = (SELECT Cod_ciud FROM @datos_enc_ciud WHERE LEFT(Cod_ciud,2) = (SELECT Cod_depto FROM @datos_enc_depto))
				BREAK --sale del ciclo termina busqueda	
			END
		END	
		--Borra registros de tablas temporales
		DELETE FROM @datos_enc_ciud 
		DELETE @datos_enc_depto
		--Fin busqueda por palabras de la cadena separadas por '-'	

		--busqueda cambiando espacios por '-'
		SELECT @cadena = REPLACE(@cadena_aux,' ','-'),@posfin = 1	
		--separar cadenas utilizando el '-' como delimitador
		WHILE @posfin > 0	--busca los textos entre "-" de la cadena enviada
		BEGIN
			SELECT	@posfin = CHARINDEX ('-',@cadena,@posini+1)

			IF @posfin <> 0	--encontro un "-" finalizando un texto
				SELECT	@cadena_enc = SUBSTRING(@cadena,@posini+1,@posfin-(@posini+1))
			ELSE	--no encontro un "-" finalizando una palabra
				SELECT	@cadena_enc = SUBSTRING(@cadena,@posini+1,LEN(@cadena)-(@posini))	
			
			--busca la cadena encontrada
			IF LEN(@cadena_enc) > 2 --Controla que sea mas de dos caracteres 
			BEGIN
				--buscar departamento
				SELECT @cant_reg = COUNT(*) FROM tspspg804512 with (nolock)
								WHERE	CHARINDEX(LTRIM(RTRIM(@cadena_enc)),t_dsdp_c COLLATE Latin1_General_CI_AI) <> 0
										AND t_cste_c <> '11'
				IF @cant_reg > 0
					INSERT	INTO @datos_enc_depto 
						SELECT	DISTINCT t_cste_c	--codigo departamento
						FROM	tspspg804512 with (nolock)
						WHERE	CHARINDEX(LTRIM(RTRIM(@cadena_enc)),t_dsdp_c COLLATE Latin1_General_CI_AI) <> 0
					
				--buscar ciudad
				IF @cant_reg = 0
					INSERT	INTO @datos_enc_ciud 
						SELECT	DISTINCT t_city_c	--codigo ciudad
						FROM	tspspg804512 with (nolock)
						WHERE	CHARINDEX(LTRIM(RTRIM(@cadena_enc)),t_dsca_c COLLATE Latin1_General_CI_AI) <> 0
			END			
			SET @posini = @posfin
		END
		
		--Validacion de resultados
		SELECT @cant_reg_ciu = COUNT(*) FROM @datos_enc_ciud  --cantidad de ciudades encontradas
		SELECT @cant_reg_dep = COUNT(*) FROM @datos_enc_depto  --cantidad de departamentos encontrados	
		SELECT @cant_reg = 0   
		
		IF @cant_reg_ciu = 1 --Se encuentra ciudad
		BEGIN
			INSERT	INTO @datos_enc 
				SELECT	DISTINCT t_city_c	--codigo ciudad
						,t_dsca_c	--nombre ciudad
						,t_cste_c	--codigo departamento
						,t_dsdp_c	--nombre departamento
						,t_idco_c	--indicativo
				FROM	tspspg804512 with (nolock)
				WHERE	t_city_c = (SELECT Cod_ciud FROM @datos_enc_ciud)
			BREAK --sale del ciclo termina busqueda
		END
		
		IF @cant_reg_ciu > 1 AND @cant_reg_dep = 1 --mas de una ciudad encontrada un solo departamento
		BEGIN
			SELECT @cant_reg = COUNT(*) FROM @datos_enc_ciud WHERE LEFT(Cod_ciud,2) = (SELECT Cod_depto FROM @datos_enc_depto)
			IF @cant_reg = 1
			BEGIN
				INSERT	INTO @datos_enc 
					SELECT	DISTINCT t_city_c	--codigo ciudad
							,t_dsca_c	--nombre ciudad
							,t_cste_c	--codigo departamento
							,t_dsdp_c	--nombre departamento
							,t_idco_c	--indicativo
					FROM	tspspg804512 with (nolock)
					WHERE	t_city_c = (SELECT Cod_ciud FROM @datos_enc_ciud WHERE LEFT(Cod_ciud,2) = (SELECT Cod_depto FROM @datos_enc_depto))
				BREAK --sale del ciclo termina busqueda	
			END
		END	
		--Borra registros de tablas temporales
		DELETE FROM @datos_enc_ciud 
		DELETE @datos_enc_depto
		--Fin busqueda cambiando espacios por '-'
		
		--Busqueda en nemotecnia
		SELECT @cadena = REPLACE(@cadena_aux,' ','-'),@posfin = 1	
		--separar cadenas utilizando el '-' como delimitador
		WHILE @posfin > 0	--busca los textos entre "-" de la cadena enviada
		BEGIN
			SELECT	@posfin = CHARINDEX ('-',@cadena,@posini+1)

			IF @posfin <> 0	--encontro un "-" finalizando un texto
				SELECT	@cadena_enc = SUBSTRING(@cadena,@posini+1,@posfin-(@posini+1))
			ELSE	--no encontro un "-" finalizando una palabra
				SELECT	@cadena_enc = SUBSTRING(@cadena,@posini+1,LEN(@cadena)-(@posini))	
			
			--busca la cadena encontrada
			IF LEN(@cadena_enc) > 2 --Controla que sea mas de dos caracteres 
			BEGIN
				--buscar ciudad
				INSERT	INTO @datos_enc_ciud 
					SELECT	DISTINCT t_city_c	--codigo ciudad
					FROM	tspspg804512 with (nolock)
					WHERE	CHARINDEX(LTRIM(RTRIM(@cadena_enc)),t_nmta_c COLLATE Latin1_General_CI_AI) <> 0
			END			
			SET @posini = @posfin
		END
		
		--Validacion de resultados
		SELECT @cant_reg_ciu = COUNT(*) FROM @datos_enc_ciud  --cantidad de ciudades encontradas
		SELECT @cant_reg = 0   
		
		IF @cant_reg_ciu = 1 --Se encuentra ciudad
		BEGIN
			INSERT	INTO @datos_enc 
				SELECT	DISTINCT t_city_c	--codigo ciudad
						,t_dsca_c	--nombre ciudad
						,t_cste_c	--codigo departamento
						,t_dsdp_c	--nombre departamento
						,t_idco_c	--indicativo
				FROM	tspspg804512 with (nolock)
				WHERE	t_city_c = (SELECT Cod_ciud FROM @datos_enc_ciud)
			BREAK --sale del ciclo termina busqueda
		END
		
		--Borra registros de tablas temporales
		DELETE FROM @datos_enc_ciud 
		DELETE @datos_enc_depto		
		--Fin Busqueda en nemotecnia
		
		--Inicio busqueda por ciudad a donde se despacha
		SELECT @cadena = REPLACE(@cadena_aux,' ','-'),@posfin = 1	
		--separar cadenas utilizando el '-' como delimitador
		WHILE @posfin > 0	--busca los textos entre "-" de la cadena enviada
		BEGIN
			SELECT	@posfin = CHARINDEX ('-',@cadena,@posini+1)

			IF @posfin <> 0	--encontro un "-" finalizando un texto
				SELECT	@cadena_enc = SUBSTRING(@cadena,@posini+1,@posfin-(@posini+1))
			ELSE	--no encontro un "-" finalizando una palabra
				SELECT	@cadena_enc = SUBSTRING(@cadena,@posini+1,LEN(@cadena)-(@posini))	
			
			--busca la cadena encontrada
			IF LEN(@cadena_enc) > 2 --Controla que sea mas de dos caracteres 
			BEGIN
				--buscar ciudad
				INSERT	INTO @datos_enc_ciud 
					SELECT	DISTINCT t_city_c	--codigo ciudad
					FROM	tspspg804512 with (nolock)
					WHERE	CHARINDEX(LTRIM(RTRIM(@cadena_enc)),t_city_c COLLATE Latin1_General_CI_AI) <> 0
							AND t_dspo_c = 1
			END			
			SET @posini = @posfin
			
		END
		
		--Validacion de resultados
		SELECT @cant_reg_ciu = COUNT(*) FROM @datos_enc_ciud  --cantidad de ciudades encontradas

		IF @cant_reg_ciu = 1 --Se encuentra ciudad
		BEGIN
			INSERT	INTO @datos_enc 
				SELECT	DISTINCT t_city_c	--codigo ciudad
						,t_dsca_c	--nombre ciudad
						,t_cste_c	--codigo departamento
						,t_dsdp_c	--nombre departamento
						,t_idco_c	--indicativo
				FROM	tspspg804512 with (nolock)
				WHERE	t_city_c = (SELECT Cod_ciud FROM @datos_enc_ciud)
			BREAK --sale del ciclo termina busqueda
		END
		
		--Borra registros de tablas temporales
		DELETE FROM @datos_enc_ciud 
		DELETE @datos_enc_depto		
		--Fin busqueda por ciudad a donde se despacha

		BREAK --sale del ciclo termina busqueda
	END	
	
	SELECT @cant_reg = COUNT(*) FROM @datos_enc --cantidad departamentos encontrados
	IF @cant_reg = 1 
		SELECT @resultado = 'SI:'+LTRIM(RTRIM(Cod_ciud))
							+'|'+LTRIM(RTRIM(Nom_ciud))
							+'|'+LTRIM(RTRIM(Cod_depto))
							+'|'+LTRIM(RTRIM(Nom_depto))
							+'|'+LTRIM(RTRIM(Indicativo)) FROM @datos_enc
	ELSE
		SELECT @resultado = 'NO:'

	RETURN @resultado	
END