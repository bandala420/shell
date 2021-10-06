use MatrixRestDB

SELECT [Id_Producto],[TipoProdBase],[DescripcionLarga],[Status],[AplicaReceta],[AplicaDesperdicio],[AplicaPromo],[AplicaCEmpleado],[MainGrupo],[Grupo],[Clasificacion],[ImpuestoComedor],[ImpuestoAuto],[CostoUnitario],[CostoFrente],[CostoAuto],[CostoPapelFrente],[CostoPapelAuto],[OtroCostoIn],[OtroCostoOut],[PrecioComedor],[PrecioAuto],[CostoDistribucionAlimento],[CostoDistribucionPapel],[CostoDistribucionOtros]
FROM [MatrixRestDB].[dbo].[CatalogoProductos]