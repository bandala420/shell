use MatrixRestDB
declare @thirtydaysago datetime
declare @now datetime
set @now = getdate()
set @thirtydaysago = dateadd(day,-35,@now)

SELECT CONVERT(VARCHAR(10),[Fecha],111),[RegisterPosID],[StationID],[RegisterPosType],[VentaBrutaProducto],[ImpuestoProducto],[VentaBrutaNoProducto],[ImpuestoNoProducto],[Transacciones],[Descuentos]
FROM [MatrixRestDB].[dbo].[SalesByRegister]
WHERE Fecha BETWEEN @thirtydaysago AND @now