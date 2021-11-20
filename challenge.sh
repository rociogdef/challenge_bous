#!/bin/bash
export PGHOST=127.0.0.1
export PGPORT=5432
export PGDATABASE=bd_chbous
export PGUSER=postgres
export PGPASSWORD=facil680

excelfile=$1


export dirtemp=$PWD/"wdir"




[ $# -le 0 ] &&echo "Favor de especificar  un archivo de entrada .xlsx"&& exit 1

if  [ ! -d $dirtemp ]; then
      mkdir $dirtemp
fi

if [ -f $excelfile ]
then
   cp $excelfile $dirtemp
else
   echo "No existe el archivo $excelfile"
   exit 1
fi


if [ ! "$( psql -tAc  "SELECT 1 FROM pg_database WHERE datname='bd_chbous'" )" = '1' ]
then
    echo "La base de datos no existe"
    exit 1
fi

echo "Ejecutando validación del encabezado"
# . ./ev1/Scripts/activate

python valida_header.py $excelfile 

[ $? -ne 0 ] && echo "Error en la validacion del encabezado" && exit 1
#deactivate

echo "Ejecutando carga y cálculos "
PROC_ID=`psql -f carga_y_calculos.sql`



[ $? -ne 0 ] && echo "Existe un error en la carga y calculos del archivo CSV " && exit 1

if [ -d $dirtemp/"procesados/" ]
then
   echo  "El archivo $excelfile se moverá a la carpeta ", $dirtemp/"procesados/"
else
   mkdir $dirtemp/"procesados/"
fi


mv $dirtemp/$excelfile $dirtemp/"procesados"
retVal=$?
[ $retVal -ne 0 ] && echo "No es posible mover el archivo al directorio de archivos procesados" && exit 1


exit 0