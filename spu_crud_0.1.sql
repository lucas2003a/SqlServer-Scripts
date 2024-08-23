use SIGE_TSC_FRANK;
go

/*
SELECT * FROM CF_SEG_Autoriza_ReImpresion
exec spu_CF_SEG_Autoriza_ReImpresion_administrar;
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'V', 'ELNOOBMAN';
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'I','VAÑLIDATE992','EALARCO','ESTACION1';
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'U','AHUAMANP','EALARCO','ESTACION2';
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'D','ATUNCARV','EALARCO','ESTACION1';
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'U','lucas2003cxcx','EALARCO','ESTACION1';
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'D','ATUNCARV','EALARCO','ESTACION1';
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'A','ATUNCARV_','MASTER','ESTACION1';
*/

ALTER procedure spu_CF_SEG_Autoriza_ReImpresion_administrar
	@opcion char(1) = 'V',
	@cod_usuario varchar(30) = '',	
	@COD_USUARIO_CREACION varchar(25) = '',
	@COD_ESTACION varchar(25) = ''	
as
begin
 set nocount on;
 set xact_abort on;

	declare @sms_error varchar(100);
	-- Validadciones
	
	begin
		if @opcion not in('V','I','U','D','A')
			begin
				set @sms_error = 'Ingrese una opción valida (V,I,U,D,A)';
				raiserror(@sms_error, 16, 1);
				return;
			end
		if @opcion != 'V'
			begin
				if @cod_usuario != ''
					begin
						if @opcion = 'I'
							begin
								if exists(select 1 from CF_SEG_Autoriza_ReImpresion where COD_USUARIO = @cod_usuario)
								begin
									set @sms_error = 'EL usuario existe';
									raiserror(@sms_error,16,1);
									return;
								end;
							end;
						if @opcion = 'U'
							begin
								if not exists(select 1 from CF_SEG_Autoriza_ReImpresion where COD_USUARIO = @cod_usuario)
								begin
									set @sms_error = 'El usuario no existe';
									raiserror(@sms_error,16,1);
									return;
								end;
							end;
						if @opcion = 'D'
							begin
								if not exists(select 1 from CF_SEG_Autoriza_ReImpresion where COD_USUARIO = @cod_usuario)
									begin
										set @sms_error = 'El usuario no existe';
										raiserror(@sms_error,16,1);
										return;
									end;
								if exists(select 1 from CF_SEG_Autoriza_ReImpresion where COD_USUARIO = @cod_usuario and FLG_ACTIVO = 1)
									begin
										set @sms_error = 'El usuario ya se encuentra eliminado';
										raiserror(@sms_error, 16 ,1);
										return
									end;
							end;
						if @opcion = 'A'
							begin
								if not exists(select 1 from CF_SEG_Autoriza_ReImpresion where COD_USUARIO = @cod_usuario)
									begin
										set @sms_error = 'El usuario no existe'
										raiserror(@sms_error, 16 ,1);
										return;
									end;

								if exists(select 1 from CF_SEG_Autoriza_ReImpresion where COD_USUARIO = @cod_usuario and FLG_ACTIVO = 0)
									begin	
										set @sms_error = 'El usuario ya se encuentra activo';
										raiserror(@sms_error, 16, 1);
										return;
									end
							end;
					end;
				else
					begin
						set @sms_error = 'Especifique código del usuario';
						raiserror(@sms_error,16,1);
						return
					end;
			end
	end;
	
	if @opcion = 'V'
			begin
				select * from CF_SEG_Autoriza_ReImpresion
				--where FLG_ACTIVO = 0;
				return;
			end

	-- Inicia el crud
	begin
		begin transaction;
	
			if @opcion = 'I'
				begin
					insert into [CF_SEG_Autoriza_ReImpresion](
						COD_USUARIO, 
						REGCREATE,
						REGCREATE_USUARIO,
						REGCREATE_ESTACION
						) 
						VALUES (
							@cod_usuario,
							getdate(),
							@COD_USUARIO_CREACION,
							@COD_ESTACION
							);			
				end

			-- actualizar
			IF @OPCION = 'U'
				BEGIN
					UPDATE CF_SEG_AUTORIZA_REIMPRESION
					SET	REGUPDATE = GETDATE(),
						REGUPDATE_USUARIO = @COD_USUARIO_CREACION,
						REGUPDATE_ESTACION = @COD_ESTACION					
					WHERE COD_USUARIO = @cod_usuario;			
				END;

			-- eliminar
			if @opcion ='D'
				begin
					update CF_SEG_Autoriza_ReImpresion
						set 
							FLG_ACTIVO = 1,
							REGDELETE_USUARIO = @COD_USUARIO_CREACION,
							REGDELETE_ESTACION = @COD_ESTACION,
							REGDELETE = GETDATE()
						WHERE COD_USUARIO = @cod_usuario 
				end;
			if @opcion = 'A'
				begin
					update CF_SEG_Autoriza_ReImpresion
						set
							FLG_ACTIVO = 0,
							REGACTIVATE = GETDATE(),
							REGACTIVATE_ESTACION = @COD_ESTACION,
							REGACTIVATE_USUARIO = @COD_USUARIO_CREACION
						where COD_USUARIO = @cod_usuario
				end
		COMMIT TRANSACTION	
	end
end;