use SIGE_TSC_FRANK;
GO

ALTER TABLE [CF_SEG_Autoriza_ReImpresion] ADD FLG_ACTIVO BIT DEFAULT 0 WITH VALUES;
ALTER TABLE [CF_SEG_Autoriza_ReImpresion] ADD REGCREATE VARCHAR(25) DEFAULT '' WITH VALUES;
ALTER TABLE [CF_SEG_Autoriza_ReImpresion] ADD REGCREATE_USUARIO VARCHAR(25) DEFAULT '' WITH VALUES;
ALTER TABLE [CF_SEG_Autoriza_ReImpresion] ADD REGCREATE_ESTACION VARCHAR(25) DEFAULT '' WITH VALUES;
ALTER TABLE [CF_SEG_Autoriza_ReImpresion] ADD REGUPDATE DATETIME DEFAULT GETDATE() WITH VALUES;
ALTER TABLE [CF_SEG_Autoriza_ReImpresion] ADD REGUPDATE_USUARIO VARCHAR(25) DEFAULT '' WITH VALUES;
ALTER TABLE [CF_SEG_Autoriza_ReImpresion] ADD REGUPDATE_ESTACION VARCHAR(25) DEFAULT '' WITH VALUES;
ALTER TABLE [CF_SEG_Autoriza_ReImpresion] ADD REGDELETE DATETIME DEFAULT GETDATE() WITH VALUES;
ALTER TABLE [CF_SEG_Autoriza_ReImpresion] ADD REGDELETE_USUARIO VARCHAR(25) DEFAULT '' WITH VALUES;
ALTER TABLE [CF_SEG_Autoriza_ReImpresion] ADD REGDELETE_ESTACION VARCHAR(25) DEFAULT '' WITH VALUES;
go

ALTER TABLE CF_SEG_Autoriza_ReImpresion ADD REGACTIVATE DATETIME DEFAULT GETDATE() WITH VALUES;
ALTER TABLE CF_SEG_Autoriza_ReImpresion ADD REGACTIVATE_USUARIO VARCHAR(25) DEFAULT '' WITH VALUES;
ALTER TABLE CF_SEG_Autoriza_ReImpresion ADD REGACTIVATE_ESTACION VARCHAR(25) DEFAULT '' WITH VALUES;
go

SELECT dc.name AS DefaultConstraintName
FROM sys.default_constraints AS dc
INNER JOIN sys.columns AS c
    ON dc.parent_object_id = c.object_id
    AND dc.parent_column_id = c.column_id
WHERE c.object_id = OBJECT_ID('CF_SEG_Autoriza_ReImpresion')
  AND c.name = 'REGCREATE';

alter table CF_SEG_Autoriza_ReImpresion drop constraint DF__CF_SEG_Au__REGCR__51922D14;
alter table CF_SEG_Autoriza_ReImpresion alter column REGCREATE DATETIME NOT NULL;
alter table CF_SEG_Autoriza_ReImpresion add constraint regcreate_default default getdate() for REGCREATE;

select top 1 * from  [CF_SEG_Autoriza_ReImpresion];
go

insert into CF_SEG_Autoriza_ReImpresion values ('lucas');

select * from  [CF_SEG_Autoriza_ReImpresion];
go

use SIGE_TSC_FRANK;
go

/*exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'v', null, null, null,null,null,null, null, null,null, null;
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'I', 'ATUNCARV','2024-08-21', 'lucas','estacion1',null,null, null, null,null, null;
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'U', 'ATUNCARV','2024-08-21', 'lucas','estacion2',null,null, null, null,null, null;
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'D', 'ATUNCARV','2024-08-21', 'lucas','estacion2',null,null, null, null,null, null;
go*/

select * from CF_SEG_Autoriza_ReImpresion;
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'Z' , 'Usuario','est', 'esta';
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'I','lucas2002','EALARCO','ESTACION1';
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'U','lucas2003','EALARCO','ESTACION2';
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'D','lucas2003','EALARCO','ESTACION1';
exec spu_CF_SEG_Autoriza_ReImpresion_administrar 'U','','EALARCO','ESTACION1';