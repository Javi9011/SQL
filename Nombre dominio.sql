USE [erpln104c]
GO
/****** Object:  UserDefinedFunction [dspring].[fn_nombredominio]    Script Date: 07/10/2022 14:33:46 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
ALTER FUNCTION  [dspring].[fn_nombredominio] (@enu int,@paca VARCHAR(2),@dom varchar(12),@cust varchar(4))
RETURNS VARCHAR(50)
AS
BEGIN
DECLARE @resultado varchar(50)

select	@resultado = cast(@enu as varchar(2))+' - '+isnull(lab.t_desc,dom.t_ctnm)
from	tttadv401000 dom with (nolock)
		left join tttadv140000 lab  with (nolock) on dom.t_cpac = lab.t_cpac and dom.t_za_clab = lab.t_clab and lab.t_clan = '5'
where	dom.t_cpac = @paca and dom.t_cdom = @dom and dom.t_cust = @cust and dom.t_cnst = @enu

RETURN ISNULL(@resultado,'')
end