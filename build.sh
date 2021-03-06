
function get_deps() {
    rm -rf deps
    mkdir deps 
    cd deps
    wget http://repo1.maven.org/maven2/org/apache/thrift/libthrift/0.9.0/libthrift-0.9.0.jar
    wget https://repository.cloudera.com/content/groups/public/org/apache/hive/hive-service/0.10.0-cdh4.3.0/hive-service-0.10.0-cdh4.3.0.jar
    wget https://repository.cloudera.com/content/groups/public/org/apache/hive/hive-metastore/0.10.0-cdh4.3.0/hive-metastore-0.10.0-cdh4.3.0.jar 
    wget http://www.java2s.com/Code/JarDownload/slf4j/slf4j.api-1.6.1.jar.zip
    unzip slf4j.api-1.6.1.jar.zip
    wget http://apache.crihan.fr/dist//commons/lang/binaries/commons-lang3-3.1-bin.tar.gz
    tar xzf commons-lang3-3.1-bin.tar.gz
    cd ..
}

function get_thrift_files() {
    rm -rf thrift
    mkdir thrift
    cd thrift;
    for file in beeswax.thrift cli_service.thrift DataSinks.thrift Data.thrift Descriptors.thrift Frontend.thrift Exprs.thrift ImpalaInternalService.thrift ImpalaPlanService.thrift ImpalaService.thrift NetworkTest.thrift Partitions.thrift Planner.thrift PlanNodes.thrift parquet.thrift RuntimeProfile.thrift StateStoreService.thrift Status.thrift Types.thrift 
    do
        wget https://raw.github.com/cloudera/impala/impala-v1.0/common/thrift/$file
    done

    wget https://raw.github.com/cloudera/hive/cdh4.3.0-release/metastore/if/hive_metastore.thrift
    wget https://raw.github.com/cloudera/hue/cdh4.3.0-release/apps/beeswax/thrift/include/fb303.thrift
    #hive_metastore includes "share/if/fb303.thrift" --> change to "fb303.thrift" 
    mv hive_metastore.thrift hive_metastore.thrift.copy
    cat hive_metastore.thrift.copy | sed 's/share\/fb303\/if\/fb303.thrift/fb303.thrift/g' > hive_metastore.thrift

#Opcodes.thrift is generated by the Impala build, get a file that already exists
    wget https://raw.github.com/colinmarc/impala-ruby/master/thrift/Opcodes.thrift
    cd ..
}

function generate_java() {
    #for details see https://github.com/cloudera/impala/blob/impala-v1.0/common/thrift/CMakeLists.txt
    rm -rf gen-java
    rm -rf classes

    thrift -gen java ./thrift/ImpalaService.thrift
    thrift -gen java ./thrift/beeswax.thrift
    thrift -gen java ./thrift/Status.thrift
    thrift -gen java ./thrift/cli_service.thrift
}

get_deps
get_thrift_files
generate_java
ant compile
ant jar 

cd test
./build.sh
