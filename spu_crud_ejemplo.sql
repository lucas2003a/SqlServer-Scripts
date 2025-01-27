USE [SIGE_TSC_FRANK]
GO
/****** Object:  StoredProcedure [dbo].[AC_ACTUALIZA_DATOS_DE_CAJA]    Script Date: 21/08/2024 10:09:59 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
        
--EXEC AC_ACTUALIZA_DATOS_DE_CAJA @NUM_CAJA = '539432',@PESOBRUTOCAJA ='15.5',@PESONETOCAJA ='0',@DIMENSION ='C02',@COD_USUARIO ='vluna', @OPCION = ''        
--EXEC AC_ACTUALIZA_DATOS_DE_CAJA @NUM_CAJA = '273',@PESOBRUTOCAJA ='15',@PESONETOCAJA ='0',@DIMENSION ='001',@COD_USUARIO ='ECARDENAS', @OPCION = ''          
        
ALTER PROCEDURE [dbo].[AC_ACTUALIZA_DATOS_DE_CAJA]        
--DECLARE         
@NUM_CAJA AS NUM_CAJA,        
@PESOBRUTOCAJA AS NUMERIC(6, 3),        
@PESONETOCAJA AS NUMERIC(6, 3),        
@DIMENSION AS COD_DIMENSIONCAJA = '',        
@COD_USUARIO AS COD_USUARIO,        
@OPCION AS CHAR(1) = '1' ,      
@cod_estacion as varchar(15) = '',                  
@cod_celula varchar(3)='',                  
@cod_turno varchar(1)='',          
@IdSolicitudPesadoCajas int =null          
/*          
 @OPCION        
    1 --> EN ACABADOS - PESO DE CAJA Y PRENDAS          
    2 --> EN AUDITORIA/REINSPECCION          
    3 --> EN ACABADOS - PESO BRUTO DE LA CAJA           
    4 --> EN ACABADOS - PESO DE CAJA Y PRENDAS , INCOMPLETO MODIFICA PACKING         
 5---> EN ACABADOS - PESO CAJA SALDOS      
*/        
AS        
BEGIN        
 SET NOCOUNT ON        
 SET XACT_ABORT ON        
        
 BEGIN        
  DECLARE @MSG_ERROR AS VARCHAR(1000)        
  DECLARE @PRENDAS_TOTAL_CAJA AS INTEGER        
  DECLARE @PRENDAS_LEIDAS AS INTEGER        
  DECLARE @TARA AS NUMERIC(6, 3)        
  --AGREGADO          
  DECLARE @NUM_PACKING AS NUM_PACKING        
  DECLARE @TIP_PACKING AS CHAR(1)        
  DECLARE @FLG_STATUS_PACKING AS CHAR(1)        
  DECLARE @FLG_STATUS_CAJA AS CHAR(1)        
  DECLARE @FLG_EN_PROCESO AS CHAR(1)        
  DECLARE @FEC_LECTURA AS DATETIME        
  DECLARE @DIMENSION_CAJA AS CHAR(3)        
  DECLARE @PESO_BRUTO_CAJA_MANUAL AS NUMERIC(18, 5)        
  DECLARE @cod_calidad_caja_saldos char(1)      
 END        
         
 BEGIN        
      
  SELECT        
   @NUM_PACKING = B.NUM_PACKING        
   ,@FLG_STATUS_CAJA = B.FLG_STATUS_CAJA        
   ,@PRENDAS_TOTAL_CAJA = SUM(A.NUM_PRENDAS)        
   ,@PRENDAS_LEIDAS = SUM(A.NUM_PRENDAS_LEIDAS)        
   ,@PESO_BRUTO_CAJA_MANUAL = B.PESO_TARA_CAJA ,      
   @cod_calidad_caja_saldos = b.COD_CALIDAD_CAJA_SALDOS      
  FROM CF_DETALLECAJA A        
  INNER JOIN CF_CAJADESPACHO B        
   ON A.NUM_CAJA = B.NUM_CAJA        
  WHERE A.NUM_CAJA = @NUM_CAJA        
  GROUP BY B.NUM_PACKING        
      ,B.FLG_STATUS_CAJA        
      ,B.COD_DIMENSIONCAJA        
      ,PESO_TARA_CAJA        
   , b.COD_CALIDAD_CAJA_SALDOS      
        
   IF @OPCION = ''      
 set @OPCION ='1'      
      
  IF @OPCION = '1'      
  begin      
 select @cod_calidad_caja_saldos      
 if @cod_calidad_caja_saldos <> ''      
 begin      
    SET @MSG_ERROR = 'CAJA ES DE SALDOS, NO SE PUEDE CERRAR POR ESTE MEDIO, IR A LA PANTALLA DE SALDOS.'        
    RAISERROR (@MSG_ERROR, 16, 1)        
    RETURN        
 end      
  end      
      
  IF @OPCION = '1' AND @FLG_STATUS_CAJA NOT IN ('P', 'R')        
  BEGIN        
   SET @MSG_ERROR = 'NO SE PUEDE MODIFICAR EL PESO DE ESTA CAJA, NO ESTA EN ACABADOS'        
   RAISERROR (@MSG_ERROR, 16, 1)        
   RETURN        
  END        
        
  IF @PRENDAS_TOTAL_CAJA <> @PRENDAS_LEIDAS AND @OPCION NOT IN ('3', '4')        
  BEGIN        
   SET @MSG_ERROR = 'FALTAN ' + LTRIM(RTRIM(STR(@PRENDAS_TOTAL_CAJA - @PRENDAS_LEIDAS))) + ' POR LEER'        
   + CHAR(10) + ' DE ' + LTRIM(RTRIM(STR(@PRENDAS_TOTAL_CAJA)))        
   RAISERROR (@MSG_ERROR, 16, 1)        
   RETURN        
  END        
        
  SET @TARA = @PESO_BRUTO_CAJA_MANUAL        
  IF (@PESOBRUTOCAJA = 0)        
  BEGIN        
   SET @MSG_ERROR = 'EL PESO BRUTO DE LA CAJA NO PUEDE SER [ 0 ]'        
   RAISERROR (@MSG_ERROR, 16, 1)        
   RETURN        
  END        
        
        
  IF @OPCION <> '3'        
  BEGIN        
   IF NOT EXISTS (SELECT        
      1        
     FROM CF_DIMENSIONCAJA        
     WHERE COD_DIMENSIONCAJA = @DIMENSION)        
   BEGIN        
    SET @MSG_ERROR = 'EL CODIGO ' + @DIMENSION + ' NO EXISTE EL REGISTRO DE DIMENSIONES DE CAJA'        
    RAISERROR (@MSG_ERROR, 16, 1)        
    RETURN        
   END        
        
        
   IF (@TARA <= 0)        
   BEGIN        
    SET @MSG_ERROR = 'EL CODIGO ' + @DIMENSION + ' NO CUENTA CON TARA, FAVOR REGISTRARLA...'        
    RAISERROR (@MSG_ERROR, 16, 1)        
    RETURN        
   END        
        
   IF (@PESOBRUTOCAJA < @TARA)        
        
   BEGIN        
    SET @MSG_ERROR = 'EL PESO BRUTO DE LA CAJA [' + CONVERT(VARCHAR, @PESOBRUTOCAJA) + '] NO PUEDE SER MENOR QUE LA TARA [' + CONVERT(VARCHAR, @TARA) + ']'        
    RAISERROR (@MSG_ERROR, 16, 1)        
    RETURN        
   END        
        
   IF (@PESOBRUTOCAJA - @TARA <= 0)        
   BEGIN        
    SET @MSG_ERROR = 'EL PESO NETO DE LA CAJA [' + CONVERT(VARCHAR, @PESOBRUTOCAJA) + '] NO PUEDE SER MENOR QUE  [' + CONVERT(VARCHAR, 0) + ']'        
    RAISERROR (@MSG_ERROR, 16, 1)        
    RETURN        
   END        
        
        
  END        
        
  SELECT        
   @TIP_PACKING = TIP_PACKING        
   ,@FLG_STATUS_PACKING = FLG_STATUS_PACKING        
  FROM CF_PAKINGLIST        
  WHERE NUM_PACKING = @NUM_PACKING        
        
  DECLARE @COD_LINPRO AS COD_LINPRO        
        
  SELECT        
   @COD_LINPRO = COD_LINPRO        
  FROM CF_TIPOPACKING        
  WHERE TIP_PACKING = @TIP_PACKING        
        
  IF @OPCION = '4'        
  BEGIN        
   IF @PRENDAS_LEIDAS = 0        
   BEGIN        
    SET @MSG_ERROR = 'TIENE COMO MINIMO LEER UNA PRENDA'        
    RAISERROR (@MSG_ERROR, 16, 1)        
    RETURN        
   END        
  END        
        
  if @OPCION = '5'      
  begin      
 if @FLG_STATUS_CAJA <> 'R'      
 begin      
   SET @MSG_ERROR = 'CAJA NO HA SIDO REALIZADA, NO SE PUEDE COLOCAR UN PESO'        
  RAISERROR (@MSG_ERROR, 16, 1)        
  RETURN        
 end      
  end      
  --  IF @cod_turno='' or @cod_turno is null      
  --begin      
  -- RAISERROR('Favor de salir y volver a entrar del sige. Motivo: Actualizacion Pesado Cajas - Acabados!',16,1)      
  -- RETURN      
  --end      
      
 END        
        
 BEGIN TRY        
  BEGIN TRANSACTION;        
        
  IF (@FLG_STATUS_CAJA = 'P') AND @OPCION <> '3'        
  BEGIN        
        
   IF @OPCION = '4'        
   BEGIN        
        
    INSERT cf_detallecaja_bitacora        
     SELECT        
      *        
      ,@Cod_usuario        
      ,GETDATE()        
      ,'U'        
     FROM CF_DetalleCaja        
     WHERE Num_Caja = @Num_Caja;        
        
    UPDATE a        
    SET Num_Prendas = Num_Prendas_Leidas        
    FROM CF_DetalleCaja a        
    WHERE Num_Caja = @NUM_CAJA;        
        
    delete a from CF_DetalleCaja a        
    WHERE a.Num_Caja = @NUM_CAJA        
    and a.Num_Prendas = 0        
        
    SELECT        
     @PRENDAS_TOTAL_CAJA = SUM(Num_Prendas)        
    FROM CF_DetalleCaja        
    WHERE Num_Caja = @NUM_CAJA        
        
    UPDATE a        
    SET Num_Prendas = @PRENDAS_TOTAL_CAJA        
    FROM cf_cajadespacho a        
    WHERE Num_Caja = @NUM_CAJA        
        
   END        
        
   IF @TIP_PACKING = 'V'        
   BEGIN        
        
    DECLARE @FLG_GENERADA_DESDE_PACKING AS CHAR(1)        
    DECLARE @NUM_CAJA_SALDOS AS INT        
        
    SELECT        
     @NUM_CAJA_SALDOS = NUM_CAJA        
     ,@FLG_GENERADA_DESDE_PACKING = FLG_GENERADA_DESDE_PACKING        
    FROM SL_CAJADESPACHO        
    WHERE NUM_CAJA_DESTINO = @NUM_CAJA        
        
    IF ISNULL(@FLG_GENERADA_DESDE_PACKING, 'N') = 'S'        
    BEGIN        
     DELETE SL_DETALLECAJA        
     WHERE NUM_CAJA = @NUM_CAJA_SALDOS        
        
     DELETE SL_CAJADESPACHO        
     WHERE NUM_CAJA = @NUM_CAJA_SALDOS        
    END        
        
    EXEC SL_GENERA_CAJA_SALDOS_DESDE_PACKING @NUM_CAJA = @NUM_CAJA        
   END        
      
   IF @FLG_STATUS_CAJA = 'P'        
   BEGIN        
    SET @FLG_STATUS_CAJA = 'R'        
    SET @FLG_EN_PROCESO = ''        
   END        
   ELSE        
   BEGIN        
    IF @FLG_STATUS_CAJA <> 'R'        
    BEGIN        
     SET @FLG_STATUS_CAJA = 'R'        
     SET @FLG_EN_PROCESO = ''        
    END        
   END        
        
   SET @FEC_LECTURA = GETDATE()        
        
   UPDATE CF_CAJADESPACHO        
   SET FLG_STATUS_CAJA = @FLG_STATUS_CAJA        
     ,FLG_ENPROCESO = @FLG_EN_PROCESO        
     ,FEC_REALIZACION = @FEC_LECTURA        
     ,NUM_PRODUCTOS_COLOR_ASOCIADOS = DBO.CF_CAJA_DESPACHO_DEVUELVE_NRO_PRODUCTOS_COLOR(NUM_CAJA)        
     ,COD_ALMACEN_UBICACION = '53'        
     ,COD_UBICACION = '00000'        
     ,COD_USUARIO_UBICACION = @COD_USUARIO        
     ,COD_ESTACION_UBICACION = SUSER_NAME()        
     ,NUM_IMPRESION_ICA = 0        
     ,FLG_STATUS_CUSTODIA = 'N'        
   WHERE NUM_CAJA = @NUM_CAJA        
        
   UPDATE CF_PAKINGLIST        
   SET FLG_STATUS_PACKING = 'E'        
   WHERE NUM_PACKING = @NUM_PACKING        
        
      
   IF @FLG_STATUS_CAJA = 'R'        
   BEGIN        
      
   INSERT CF_CAJADESPACHO_REALIZACIONES (NUM_CAJA,        
   FEC_MOVSTK,        
   COD_USUARIO,        
   COD_ESTACION,        
   FEC_CREACION)        
    VALUES (@NUM_CAJA, @FEC_LECTURA, @COD_USUARIO, SUSER_NAME(), GETDATE())        
      
    SELECT        
     COD_ORDPRO        
     ,COD_PRESENT        
     ,COD_TALLA        
     ,SUM(NUM_PRENDAS) AS NUM_PRENDAS INTO #DETALLECAJA        
    FROM CF_DETALLECAJA        
    WHERE NUM_CAJA = @NUM_CAJA        
    GROUP BY COD_ORDPRO        
        ,COD_PRESENT        
        ,COD_TALLA        
        
    UPDATE CF_STOCKS_ACABADOS        
    SET NRO_PRENDAS_ENCAJADAS_COMPLETAS = NRO_PRENDAS_ENCAJADAS_COMPLETAS + B.NUM_PRENDAS        
    FROM CF_STOCKS_ACABADOS A        
    INNER JOIN #DETALLECAJA B        
     ON A.COD_ORDPRO = B.COD_ORDPRO        
     AND A.COD_PRESENT = B.COD_PRESENT        
     AND A.COD_TALLA = B.COD_TALLA        
    WHERE A.COD_ALMACEN = '53'        
    AND COD_LINPRO = @COD_LINPRO        
      
   END        
  END        
        
  IF @OPCION = '3'      
  BEGIN      
   UPDATE CF_CAJADESPACHO        
   SET PESO_TARA_CAJA = @PESOBRUTOCAJA       
  ,COD_USUARIO_PESO = @COD_USUARIO        
  ,FECHA_PESO = GETDATE()      
   WHERE NUM_CAJA = @NUM_CAJA        
  END      
      
  IF @OPCION <> '3'      
  BEGIN      
      
   UPDATE CF_CAJADESPACHO        
 SET COD_DIMENSIONCAJA =  @DIMENSION       
    ,PESOBRUTOCAJA =  @PESOBRUTOCAJA        
    ,PESONETOCAJA =   @PESOBRUTOCAJA - @TARA      
    ,COD_USUARIO_ENCAJADO =  @COD_USUARIO      
    ,COD_USUARIO_ENCAJADO_AUDITORIA = CASE  WHEN FLG_STATUS_CAJA IN ('I', 'A') THEN @COD_USUARIO ELSE COD_USUARIO_ENCAJADO_AUDITORIA  END        
    ,COD_ALMACEN_UBICACION = CASE  WHEN @FLG_STATUS_CAJA = 'R' THEN '53'  ELSE COD_ALMACEN_UBICACION  END        
    ,COD_UBICACION =  CASE  WHEN @FLG_STATUS_CAJA = 'R' THEN '00000'  ELSE COD_UBICACION  END        
  WHERE NUM_CAJA = @NUM_CAJA        
  --modificado 22/08/2023      
  --pesado cajas iayala      
      
 --IF @cod_turno ='' AND @OPCION<>'5' 
 --BEGIN  
 --RAISERROR('SALIR Y VOLVER A ENTRAR DEL SIGE. MOTIVO:CONTROL PESADO DE CAJAS',16,1)  
 --RETURN  
 --END  
  
  exec SP_PesadoCajas_SetTabladePesos '53','53',@Num_caja,@PESOBRUTOCAJA,@COD_USUARIO,@cod_celula,@cod_turno,'2','C',@IdSolicitudPesadoCajas       
  END      
       
        
  COMMIT TRANSACTION;        
 END TRY        
 BEGIN CATCH        
  EXEC SIST_ObtenerInfoDeError @MSG_ERROR = @MSG_ERROR OUTPUT        
                ,@MODO = '1';        
  IF (XACT_STATE()) = -1        
  BEGIN        
   ROLLBACK TRANSACTION;        
   SET @MSG_ERROR = 'La transacción ha sido revertida...!!' + CHAR(10) + CHAR(10) + @MSG_ERROR;        
  END;        
        
  IF (XACT_STATE()) = 1        
  BEGIN        
   COMMIT TRANSACTION;        
  END;        
      
  RAISERROR (@MSG_ERROR, 16, 1);        
      
 END CATCH;        
        
--DROP TABLE #DETALLECAJA        
        
END 