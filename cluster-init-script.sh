#!/bin/sh

#
# ----- setup the below vars in the cluster's environment variables ------
#
# HIVE_USERNAME={{secrets/your-secrept-scope/your-user}}
# HIVE_PASSWORD={{secrets/your-secrept-scope/your-password}}
# HIVE_URL={{secrets/your-secrept-scope/your-jdbc-url}}
#

# script to configure databricks for external metastore
cp -r /dbfs/databricks/hive_metastore_jar /databricks/hive_metastore_jars

sed -i 's/"spark\.sql\.hive\.metastore\.version" = "0\.13\.0"/"spark.sql.hive.metastore.version" = "3.1.0"/' /databricks/driver/conf/spark-branch.conf

sed -i 's|"spark\.sql\.hive\.metastore\.jars" = "/databricks/databricks-hive/\*"|"spark.sql.hive.metastore.jars" = "/databricks/hive_metastore_jars/*"|' /databricks/driver/conf/spark-branch.conf

# ---- Read secrets ----
HIVE_USERNAME="${HIVE_USERNAME:?METASTORE_USER not set}"
HIVE_PASSWORD="${HIVE_PASSWORD:?METASTORE_PASSWORD not set}"
HIVE_URL="${HIVE_URL:?METASTORE_URL not set}"

cat <<EOF > /databricks/driver/conf/00-custom-spark.conf
[driver] {

     "spark.hadoop.javax.jdo.option.ConnectionDriverName" = "org.mariadb.jdbc.Driver"
     "spark.hadoop.javax.jdo.option.ConnectionURL" = "$HIVE_URL"
     "spark.hadoop.javax.jdo.option.ConnectionUserName" = "$HIVE_USERNAME"
     "spark.hadoop.javax.jdo.option.ConnectionPassword" = "$HIVE_PASSWORD"

}
EOF
