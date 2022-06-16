#!/bin/sh

pushd .
cd ${project.build.directory}

parcel_name="${project.build.finalName}"
mkdir $parcel_name

decompressed_dir="extract"

presto_download_name="presto.tar.gz"
presto_download_url="${pkg_url}"

echo "downloading package from :"${pkg_url}
# curl -L -o $presto_download_name $presto_download_url
cp ~/Downloads/trino-server-385.tar.gz $presto_download_name
echo "downloaded package from :"${pkg_url}

mkdir $decompressed_dir
tar xzf $presto_download_name -C $decompressed_dir

presto_dir=`\ls $decompressed_dir`
for file in `\ls $decompressed_dir/$presto_dir`; do
  mv $decompressed_dir/$presto_dir/$file $parcel_name
done
rm -rf $decompressed_dir

cp -a ${project.build.outputDirectory}/meta ${parcel_name}
ln -s /etc/presto/conf ${parcel_name}/etc

## 修改launcher
printf '$-0i\nJAVA_HOME='${java_home}'\n.\nw\n' | ex -s ${parcel_name}/bin/launcher
printf '$-0i\nPATH=$JAVA_HOME/bin:$PATH\n.\nw\n' | ex -s ${parcel_name}/bin/launcher

tar zcf ${parcel_name}.parcel ${parcel_name}/ --owner=root --group=root

mkdir repository
# for i in el7 el6 sles11 lucid precise squeeze wheezy; do
for i in el7; do
  cp ${parcel_name}.parcel repository/${parcel_name}-${i}.parcel
  shasum repository/${parcel_name}-${i}.parcel | awk '{print $1}'> repository/${parcel_name}-${i}.parcel.sha
done

cd repository
curl https://raw.githubusercontent.com/cloudera/cm_ext/master/make_manifest/make_manifest.py | python

popd
