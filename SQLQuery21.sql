select	'DEV_UNIDADES' [Partner Cliente Receptor],tdsls400.t_stbp [Partner Cliente],tdsls400.t_ofbp [concepto],cisli245.t_slso [orden],cisli245.t_pono [linea],
		cisli245.t_ityp+'-'+cast(cisli245.t_idoc as varchar(9)) [factura],
		cast(dateadd(hour,-5,tdsls400.t_odat) as date) [fecha grabacion orden],
		cast(dateadd(hour,-5,tdsls401.t_prdt) as date) [fecha planificada entrega],
		cast(dateadd(hour,-5,cisli245.t_ddat) as date) [fecha entrega real],	--fecha de recepcion
		cast(dateadd(hour,-5,cisli205.t_idat) as date) [fecha factura],
		case tcibd001.t_kitm when 10 then tdsls403.t_sitm else cisli245.t_item end [item],
		case tcibd001.t_kitm when 10 then cisli245.t_item else '' end [combo],
		cisli245.t_cwar [bodega],--cisli245.t_corn [orden cliente], --facc-04jul2018 - se toma la orden del cliente de la cabecera de la orden
		tdsls400.t_corn [orden cliente],
		case tcibd001.t_kitm when 10 then tdsls403.t_qibm*cisli245.t_dqua else cisli245.t_dqua end [valor]
from	tcisli245512 cisli245 with (nolock)
		left join tcisli205512 cisli205 with (nolock) on cisli205.t_ityp = cisli245.t_ityp and cisli205.t_idoc = cisli245.t_idoc
		join ttdsls401512 tdsls401 with (nolock) on tdsls401.t_orno = cisli245.t_slso and tdsls401.t_pono = cisli245.t_pono and tdsls401.t_sqnb = dspring.fn_seqlineaov(tdsls401.t_orno,tdsls401.t_pono)
		join ttdsls400512 tdsls400 with (nolock) on tdsls400.t_orno = tdsls401.t_orno
		join ttdsls094512 tdsls094 with (nolock) on tdsls094.t_sotp = tdsls400.t_sotp
		join ttcibd001512 tcibd001 with (nolock) on tdsls401.t_item = tcibd001.t_item
		left join ttdsls403512 tdsls403 with (nolock) on tdsls401.t_orno = tdsls403.t_orno and tdsls401.t_pono = tdsls403.t_pono and tdsls401.t_sqnb = tdsls403.t_sqnb
where	tdsls094.t_reto = 1 and tdsls094.t_cnsr = 2
union all
--seleccion de devoluciones - valor Bruto
select	'DEV_VALOR_BRUTO' [Partner Cliente Receptor],tdsls400.t_stbp [Partner Cliente],tdsls400.t_ofbp [concepto],cisli245.t_slso [orden],cisli245.t_pono [linea],
		cisli245.t_ityp+'-'+cast(cisli245.t_idoc as varchar(9)) [factura],
		cast(dateadd(hour,-5,tdsls400.t_odat) as date) [fecha grabacion orden],
		cast(dateadd(hour,-5,tdsls401.t_prdt) as date) [fecha planificada entrega],
		cast(dateadd(hour,-5,cisli245.t_ddat) as date) [fecha entrega real],	--fecha de recepcion
		cast(dateadd(hour,-5,cisli205.t_idat) as date) [fecha factura],
		case tcibd001.t_kitm when 10 then dspring.fn_lineacombo(tdsls401.t_orno,tdsls401.t_pono,1) else cisli245.t_item end [item],
		case tcibd001.t_kitm when 10 then cisli245.t_item else '' end [combo],
		cisli245.t_cwar [bodega],--cisli245.t_corn [orden cliente],--facc-04jul2018 - se toma la orden del cliente de la cabecera de la orden
		tdsls400.t_corn [orden cliente],
		cisli245.t_amti [valor]		
		--cisli245.t_amth_1 [valor]
from	tcisli245512 cisli245 with (nolock)
		left join tcisli205512 cisli205 with (nolock) on cisli205.t_ityp = cisli245.t_ityp and cisli205.t_idoc = cisli245.t_idoc
		join ttdsls401512 tdsls401 with (nolock) on tdsls401.t_orno = cisli245.t_slso and 
			 tdsls401.t_pono = cisli245.t_pono and tdsls401.t_sqnb = dspring.fn_seqlineaov(tdsls401.t_orno,tdsls401.t_pono)
		join ttdsls400512 tdsls400 with (nolock) on tdsls400.t_orno = tdsls401.t_orno
		join ttdsls094512 tdsls094 with (nolock) on tdsls094.t_sotp = tdsls400.t_sotp
		join ttcibd001512 tcibd001 with (nolock) on tdsls401.t_item = tcibd001.t_item
where	tdsls094.t_reto = 1 and tdsls094.t_cnsr = 2
union all
--seleccion de devoluciones - valor descuento de linea
select	'DEV_VALOR_DESC_LINEA' [Partner Cliente Receptor],tdsls400.t_stbp [Partner Cliente],tdsls400.t_ofbp [concepto],cisli245.t_slso [orden],cisli245.t_pono [linea],
		cisli245.t_ityp+'-'+cast(cisli245.t_idoc as varchar(9)) [factura],
		cast(dateadd(hour,-5,tdsls400.t_odat) as date) [fecha grabacion orden],
		cast(dateadd(hour,-5,tdsls401.t_prdt) as date) [fecha planificada entrega],
		cast(dateadd(hour,-5,cisli245.t_ddat) as date) [fecha entrega real],	--fecha de recepcion
		cast(dateadd(hour,-5,cisli205.t_idat) as date) [fecha factura],
		case tcibd001.t_kitm when 10 then dspring.fn_lineacombo(tdsls401.t_orno,tdsls401.t_pono,1) else cisli245.t_item end [item],
		case tcibd001.t_kitm when 10 then cisli245.t_item else '' end [combo],
		cisli245.t_cwar [bodega],--cisli245.t_corn [orden cliente],--facc-04jul2018 - se toma la orden del cliente de la cabecera de la orden
		tdsls400.t_corn [orden cliente],
		cisli245.t_ldai [valor]
from	tcisli245512 cisli245 with (nolock)
		left join tcisli205512 cisli205 with (nolock) on cisli205.t_ityp = cisli245.t_ityp and cisli205.t_idoc = cisli245.t_idoc
		join ttdsls401512 tdsls401 with (nolock) on tdsls401.t_orno = cisli245.t_slso and 
			 tdsls401.t_pono = cisli245.t_pono and tdsls401.t_sqnb = dspring.fn_seqlineaov(tdsls401.t_orno,tdsls401.t_pono)
		join ttdsls400512 tdsls400 with (nolock) on tdsls400.t_orno = tdsls401.t_orno
		join ttdsls094512 tdsls094 with (nolock) on tdsls094.t_sotp = tdsls400.t_sotp
		join ttcibd001512 tcibd001 with (nolock) on tdsls401.t_item = tcibd001.t_item
where	tdsls094.t_reto = 1 and tdsls094.t_cnsr = 2
union all
--seleccion de devoluciones - valor descuento de orden
select	'DEV_VALOR_DESC_ORDEN' [Partner Cliente Receptor],tdsls400.t_stbp [Partner Cliente],tdsls400.t_ofbp [concepto],cisli245.t_slso [orden],cisli245.t_pono [linea],
		cisli245.t_ityp+'-'+cast(cisli245.t_idoc as varchar(9)) [factura],
		cast(dateadd(hour,-5,tdsls400.t_odat) as date) [fecha grabacion orden],
		cast(dateadd(hour,-5,tdsls401.t_prdt) as date) [fecha planificada entrega],
		cast(dateadd(hour,-5,cisli245.t_ddat) as date) [fecha entrega real],	--fecha de recepcion
		cast(dateadd(hour,-5,cisli205.t_idat) as date) [fecha factura],
		case tcibd001.t_kitm when 10 then dspring.fn_lineacombo(tdsls401.t_orno,tdsls401.t_pono,1) else cisli245.t_item end [item],
		case tcibd001.t_kitm when 10 then cisli245.t_item else '' end [combo],
		cisli245.t_cwar [bodega],--cisli245.t_corn [orden cliente],--facc-04jul2018 - se toma la orden del cliente de la cabecera de la orden
		tdsls400.t_corn [orden cliente],
		cisli245.t_odai [valor]
from	tcisli245512 cisli245 with (nolock)
		left join tcisli205512 cisli205 with (nolock) on cisli205.t_ityp = cisli245.t_ityp and cisli205.t_idoc = cisli245.t_idoc
		join ttdsls401512 tdsls401 with (nolock) on tdsls401.t_orno = cisli245.t_slso and 
			 tdsls401.t_pono = cisli245.t_pono and tdsls401.t_sqnb = dspring.fn_seqlineaov(tdsls401.t_orno,tdsls401.t_pono)
		join ttdsls400512 tdsls400 with (nolock) on tdsls400.t_orno = tdsls401.t_orno
		join ttdsls094512 tdsls094 with (nolock) on tdsls094.t_sotp = tdsls400.t_sotp
		join ttcibd001512 tcibd001 with (nolock) on tdsls401.t_item = tcibd001.t_item
where	tdsls094.t_reto = 1 and tdsls094.t_cnsr = 2





GO
