﻿-- 1634091036-SelectQueryGenerator.sql

-- Autor: Olimpo Bonilla Ramírez.
-- Objetivo: Query generador de columnas y atributos para compatibilidad de atributos de SQL Server a .NET Core.
-- Fecha: 2021-10-12.
-- Comentarios: Si se maneja en SQL Server, usar especificamente este script.

-- 1. Declaro variables.
DECLARE @NombreTabla varchar(255) = 'mtArticles';        /* Nombre de la tabla.  */
Declare @BaseDatos varchar(255) = 'PatosaCommercial';    /* Nombre de la Base de Datos. */
DECLARE @mtObjetos TABLE ( id bigint not null, BaseDatos varchar(255), Esquema varchar(255), Tabla varchar(255), Columna varchar(255),
                           Tipo varchar(255), Tamanio int, ColumnaConversionSQLServer varchar(max), ColumnaConversionRedshift varchar(max),
                           ColumnaCS varchar(max), ColumnaCS2 varchar(max), ExampleSetting varchar(max), ParameterName varchar(max), ExampleUpdate varchar(max), SettingToModel varchar(MAX),
                           SettingToModelJSInit varchar(MAX), SettingToModelJS varchar(MAX), SettingToModelJS2 varchar(MAX), SettingToModelJS3 varchar(MAX), SettingToModelJS4 varchar(MAX), 
                           SettingToModelJS5 varchar(MAX), ADONETParams varchar(max), ColOrdinal int primary key not null);
DECLARE @mtTablaFinal TABLE (id bigint not null, Tabla varchar(255), QuerySQLFinal text, QueryFinalAWS text);

-- 2. Inserto el query de la definición de la tabla.
INSERT INTO @mtObjetos
SELECT So.Id,
       ist.BaseDatos,
       ist.Esquema,
       ltrim(rtrim(So.name))                            AS 'Tabla',
       lower('t1.' + ltrim(rtrim(Sc.name)))             AS 'Columna',
       st.name                                          AS 'Tipo',
       sc.length                                        AS 'Tamanio',
       case when (st.name = 'decimal' or st.name = 'money') then 'cast(round(cast(t1.' + lower(ltrim(rtrim(Sc.name))) + ' as money), 2, 1) as decimal(25, 4)) as ''' + lower(ltrim(rtrim(Sc.name))) + ''', '
            when (st.name = 'int') then 'cast(t1.' + lower(ltrim(rtrim(Sc.name))) + ' as int) as ''' + lower(ltrim(rtrim(Sc.name))) + ''', '
            when (st.name = 'bigint') then 'cast(t1.' + lower(ltrim(rtrim(Sc.name))) + ' as bigint) as ''' + lower(ltrim(rtrim(Sc.name))) + ''', '
            when (st.name = 'smallint') then 'cast(t1.' + lower(ltrim(rtrim(Sc.name))) + ' as int) as ''' + lower(ltrim(rtrim(Sc.name))) + ''', '
            when (st.name = 'bit') then 'case when (t1.' + lower(ltrim(rtrim(Sc.name))) + ' is null or t1.' + lower(ltrim(rtrim(Sc.name))) + ' = 0) then 0 else 1 end as ''' + lower(ltrim(rtrim(Sc.name))) + ''', '
            when (st.name = 'smalldatetime' or st.name = 'datetime' or st.name = 'date') then 'ltrim(rtrim(convert(varchar(25), t1.' + lower(ltrim(rtrim(Sc.name))) + ', 121))) as ''' + lower(ltrim(rtrim(Sc.name))) + ''', '
            when (st.name = 'nvarchar' or st.name = 'char' or st.name = 'varchar' or st.name = 'nchar') then ' ltrim(rtrim(cast( case when (len(t1.' + lower(ltrim(rtrim(Sc.name))) + ') = 0 or t1.' + lower(ltrim(rtrim(Sc.name))) + ' is null) then null else t1.' + lower(ltrim(rtrim(Sc.name))) + ' end as varchar(' + ltrim(rtrim(sc.length)) + ')))) as ''' + lower(ltrim(rtrim(Sc.name))) + ''', '
            when (st.name = 'text' or st.name = 'ntext' ) then 'ltrim(rtrim(cast(t1.' + lower(ltrim(rtrim(Sc.name))) + ' as varchar(255)))) as ''' + lower(ltrim(rtrim(Sc.name))) + ''', '
       else '' end                                      AS 'ColumnaConversionSQLSever',
       case when (st.name = 'decimal' or st.name = 'money') then lower(ltrim(rtrim(Sc.name))) + ' numeric(25, 4) encode raw,'
            when (st.name = 'int') then lower(ltrim(rtrim(Sc.name))) + ' int encode raw, '
            when (st.name = 'bigint') then lower(ltrim(rtrim(Sc.name))) + ' bigint encode raw, '
            when (st.name = 'smallint') then lower(ltrim(rtrim(Sc.name))) + ' int encode raw, '
            when (st.name = 'bit') then lower(ltrim(rtrim(Sc.name))) + ' boolean encode raw, '
            when (st.name = 'smalldatetime' or st.name = 'datetime' or st.name = 'date') then lower(ltrim(rtrim(Sc.name))) + ' timestamp encode raw, '
            when (st.name = 'nvarchar' or st.name = 'char' or st.name = 'varchar' or st.name = 'nchar') then lower(ltrim(rtrim(Sc.name))) + ' varchar(' + ltrim(rtrim(sc.length + 1)) + ') encode raw, '
            when (st.name = 'text' or st.name = 'ntext' ) then lower(ltrim(rtrim(Sc.name))) + ' varchar(256) encode raw, '
       else '' end                                      AS 'ColumnaRedshift',
       case when (st.name = 'decimal' or st.name = 'money') then 'public decimal ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }'
            when (st.name = 'int') then 'public int ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }'
            when (st.name = 'bigint') then 'public long ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }'
            when (st.name = 'smallint') then 'public short ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }'
            when (st.name = 'bit') then 'public bool ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }'
            when (st.name = 'smalldatetime' or st.name = 'datetime' or st.name = 'date') then 'public DateTime ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }'
            when (st.name = 'nvarchar' or st.name = 'char' or st.name = 'varchar' or st.name = 'nchar') then 'public string ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }'
            when (st.name = 'text' or st.name = 'ntext' ) then 'public string ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }'
       else '' end                                      AS 'ColumnaNETCS',
       case when (st.name = 'decimal' or st.name = 'money') then '[DataNames("' + lower(ltrim(rtrim(Sc.name))) + '", "' + lower(ltrim(rtrim(Sc.name))) + '")] ' + + CHAR(13)+CHAR(10) + ' public decimal ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }' + CHAR(13)+CHAR(10)
            when (st.name = 'int') then '[DataNames("' + lower(ltrim(rtrim(Sc.name))) + '", "' + lower(ltrim(rtrim(Sc.name))) + '")] ' + + CHAR(13)+CHAR(10) + ' public int ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }' + CHAR(13)+CHAR(10)
            when (st.name = 'bigint') then '[DataNames("' + lower(ltrim(rtrim(Sc.name))) + '", "' + lower(ltrim(rtrim(Sc.name))) + '")] ' + + CHAR(13)+CHAR(10) + ' public long ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }' + CHAR(13)+CHAR(10)
            when (st.name = 'smallint') then '[DataNames("' + lower(ltrim(rtrim(Sc.name))) + '", "' + lower(ltrim(rtrim(Sc.name))) + '")] ' + + CHAR(13)+CHAR(10) + ' public short ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }' + CHAR(13)+CHAR(10)
            when (st.name = 'bit') then '[DataNames("' + lower(ltrim(rtrim(Sc.name))) + '", "' + lower(ltrim(rtrim(Sc.name))) + '")] ' + + CHAR(13)+CHAR(10) + ' public bool ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }' + CHAR(13)+CHAR(10)
            when (st.name = 'smalldatetime' or st.name = 'datetime' or st.name = 'date') then '[DataNames("' + lower(ltrim(rtrim(Sc.name))) + '", "' + lower(ltrim(rtrim(Sc.name))) + '")] ' + + CHAR(13)+CHAR(10) + ' public DateTime ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }' + CHAR(13)+CHAR(10)
            when (st.name = 'nvarchar' or st.name = 'char' or st.name = 'varchar' or st.name = 'nchar') then '[DataNames("' + lower(ltrim(rtrim(Sc.name))) + '", "' + lower(ltrim(rtrim(Sc.name))) + '")] ' + + CHAR(13)+CHAR(10) + ' public string ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }' + CHAR(13)+CHAR(10)
            when (st.name = 'text' or st.name = 'ntext' ) then '[DataNames("' + lower(ltrim(rtrim(Sc.name))) + '", "' + lower(ltrim(rtrim(Sc.name))) + '")] ' + + CHAR(13)+CHAR(10) + ' public string ' + lower(ltrim(rtrim(Sc.name))) + ' { get; set; }' + CHAR(13)+CHAR(10)
       else '' end                                      AS 'ColumnaNETCS2',
       case when (st.name = 'decimal' or st.name = 'money') then lower(ltrim(rtrim(Sc.name))) + ' = 0.00, '
            when (st.name = 'int' OR st.name = 'bigint' OR st.name = 'smallint') then lower(ltrim(rtrim(Sc.name))) + ' = 0, '
            when (st.name = 'bit') then lower(ltrim(rtrim(Sc.name))) + ' = false, '
            when (st.name = 'smalldatetime' or st.name = 'datetime' or st.name = 'date') then lower(ltrim(rtrim(Sc.name))) + ' = new DateTime(2000, 1, 1), '
            when (st.name = 'nvarchar' or st.name = 'char' or st.name = 'varchar' or st.name = 'nchar') then lower(ltrim(rtrim(Sc.name))) + ' = "Hola", '
            when (st.name = 'text' or st.name = 'ntext' ) then lower(ltrim(rtrim(Sc.name))) + ' = "Hola", '
       else '' end                                      AS 'ExampleSet',
       case when (st.name = 'decimal' or st.name = 'money') then '@' + lower(ltrim(rtrim(Sc.name))) + ','
            when (st.name = 'int' OR st.name = 'bigint' OR st.name = 'smallint') then '@' + lower(ltrim(rtrim(Sc.name))) + ','
            when (st.name = 'bit') then '@' + lower(ltrim(rtrim(Sc.name))) + ','
            when (st.name = 'smalldatetime' or st.name = 'datetime' or st.name = 'date') then '@' + lower(ltrim(rtrim(Sc.name))) + ','
            when (st.name = 'nvarchar' or st.name = 'char' or st.name = 'varchar' or st.name = 'nchar') then '@' + lower(ltrim(rtrim(Sc.name))) + ','
            when (st.name = 'text' or st.name = 'ntext' ) then '@' + lower(ltrim(rtrim(Sc.name))) + ','
       else '' end                                      AS 'ListParameter',
       lower(ltrim(rtrim(Sc.name))) + ' = @' + lower(ltrim(rtrim(Sc.name))) + ','       AS 'ExampleUPDATE',
       lower(ltrim(rtrim(Sc.name))) + ' = _Model.' + lower(ltrim(rtrim(Sc.name))) + ',' AS 'SettingToModel',
       case when (st.name = 'nvarchar' or st.name = 'char' or st.name = 'varchar' or st.name = 'nchar') then 'vm.model.' + lower(ltrim(rtrim(Sc.name))) + ' = "";'
       else 'vm.model.' + lower(ltrim(rtrim(Sc.name))) + ' = 0;' end AS 'SettingToModelJSInit',
       'vm.model.' + lower(ltrim(rtrim(Sc.name))) + ' = _Model.' + lower(ltrim(rtrim(Sc.name))) + ';' AS 'Sett',
       'vm.formData.' + lower(ltrim(rtrim(Sc.name))) + ' ' AS 'SettingToModelJS2',
			 'vm.model.' + lower(ltrim(rtrim(Sc.name))) + ' = vm.formData.' + lower(ltrim(rtrim(Sc.name))) + ';' AS 'SettingToModelJS3',
			 lower(ltrim(rtrim(Sc.name))) + ' = vm.model.' + lower(ltrim(rtrim(Sc.name))) + ';' AS 'SettingToModelJS4',
			 'vm.formData.' + lower(ltrim(rtrim(Sc.name))) + ' = vm.model.' + lower(ltrim(rtrim(Sc.name))) + ';' AS 'SettingToModelJS5',
       case when (st.name = 'decimal' or st.name = 'money') then '_oParam.Add(oDb.CreateParameter("@' + lower(ltrim(rtrim(Sc.name))) + '", entity.' + lower(ltrim(rtrim(Sc.name))) + ', DbType.Decimal));'
            when (st.name = 'int' OR st.name = 'bigint' OR st.name = 'smallint') then '_oParam.Add(oDb.CreateParameter("@' + lower(ltrim(rtrim(Sc.name))) + '", entity.' + lower(ltrim(rtrim(Sc.name))) + ', DbType.Int32));'
            when (st.name = 'bit') then '_oParam.Add(oDb.CreateParameter("@' + lower(ltrim(rtrim(Sc.name))) + '", entity.' + lower(ltrim(rtrim(Sc.name))) + ', DbType.Boolean));'
            when (st.name = 'smalldatetime' or st.name = 'datetime' or st.name = 'date') then '_oParam.Add(oDb.CreateParameter("@' + lower(ltrim(rtrim(Sc.name))) + '", entity.' + lower(ltrim(rtrim(Sc.name))) + ', DbType.Date));'
            when (st.name = 'nvarchar' or st.name = 'char' or st.name = 'varchar' or st.name = 'nchar') then '_oParam.Add(oDb.CreateParameter("@' + lower(ltrim(rtrim(Sc.name))) + '", entity.' + lower(ltrim(rtrim(Sc.name))) + '.ToUpper().Trim(), DbType.String));'
            when (st.name = 'text' or st.name = 'ntext' ) then '_oParam.Add(oDb.CreateParameter("@' + lower(ltrim(rtrim(Sc.name))) + '", entity.' + lower(ltrim(rtrim(Sc.name))) + '.ToUpper().Trim(), DbType.String));'
       else '' end                                      AS 'ADONETParameter',
       sc.colorder                                      AS 'ColOrdinal'
  FROM sysobjects SO
 INNER JOIN syscolumns SC ON (SO.ID = SC.ID)
 INNER JOIN sys.types st ON (st.system_type_id = sc.xtype) AND (st.name != @NombreTabla) AND (st.name != 'sysname')
 INNER JOIN (
              select cast(t1.object_id as int)      as [IdObjetoDB],
                     ltrim(rtrim(t2.TABLE_CATALOG)) as [BaseDatos],
                     ltrim(rtrim(t2.TABLE_SCHEMA))  as [Esquema],
                     ltrim(rtrim(t1.name))          as [Tabla]
                from sys.tables t1
               INNER JOIN INFORMATION_SCHEMA.TABLES t2 ON (t1.name = t2.TABLE_NAME)
               WHERE (ltrim(rtrim(t1.name)) = @NombreTabla)
            ) ist ON (ist.Tabla = SO.name) and (SO.id = ist.IdObjetoDB) and (ist.BaseDatos = @BaseDatos)
 WHERE (SO.xtype = 'U')
   AND (SO.Name = @NombreTabla)
 ORDER BY SC.colorder asc;

SELECT * FROM @mtObjetos;


-- 1634091036-SelectQueryGenerator.sql