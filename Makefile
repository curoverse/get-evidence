CACHEDIR=$(shell pwd)/tmp

daily: update_editors_summary dump_database vis_data_local
install: php-openid-2.2.2 textile-2.0.0 public_html/js/wz_tooltip.js public_html/js/tip_balloon.js public_html/DataTables-1.7.4 public_html/jquery-ui update_editors_summary

php-openid-2.2.2:
	[ -d php-openid/.git ] || git clone http://github.com/openid/php-openid.git
	cd php-openid && git fetch --tags http://github.com/openid/php-openid.git
	cd php-openid && git checkout 2.2.2

textile-2.0.0:
	wget -c http://textile.thresholdstate.com/file_download/2/textile-2.0.0.tar.gz
	[ `md5sum textile-2.0.0.tar.gz | head -c 32` = c4f2454b16227236e01fc1c761366fe3 ]
	tar xzf textile-2.0.0.tar.gz
	patch -p0 <textile-2.0.0-php-5.2.4.patch

DataTables-1.7.4.zip:
	wget -c http://www.datatables.net/releases/DataTables-1.7.4.zip

public_html/DataTables-1.7.4: DataTables-1.7.4.zip
	cd public_html && unzip ../DataTables-1.7.4.zip

public_html/jquery-ui:
	mkdir -p public_html/jquery-ui && cd public_html/jquery-ui && unzip ../../jquery-ui-1.8.6.custom.zip

public_html/js/wz_tooltip.js:
######## Walter Zorn's tooltip library seems to be homeless, so we
######## have a copy in our repo for now
#	wget -c http://www.walterzorn.com/scripts/wz_tooltip.zip
#	[ `md5sum wz_tooltip.zip | head -c 32` = 6b78dce5ab64ed21d278646f541fbc7a ]
########
	mkdir -p wz_tooltip
	(cd wz_tooltip && unzip ../wz_tooltip.zip)
	cp -p wz_tooltip/wz_tooltip.js public_html/js/

public_html/js/tip_balloon.js:
######## As above
#	wget -c http://www.walterzorn.com/scripts/tip_balloon.zip
########
	mkdir -p wz_tooltip
	(cd wz_tooltip && unzip ../tip_balloon.zip)
	mkdir -p public_html/js/tip_balloon
	cp -p wz_tooltip/tip_balloon/* public_html/js/tip_balloon/
	perl -p -e 's:".*?":"/js/tip_balloon/": if m:^config\.\s*BalloonImgPath:' < wz_tooltip/tip_balloon.js > public_html/js/tip_balloon.js

update_editors_summary:
	./update_editors_summary.php

import_omim: $(CACHEDIR)/OmimVarLocusIdSNP.bcp $(CACHEDIR)/morbidmap
	./import_omim.php $(CACHEDIR)/OmimVarLocusIdSNP.bcp $(CACHEDIR)/morbidmap
OmimVarLocusIdSNP.bcp:
	cd $(CACHEDIR) && wget ftp://ftp.ncbi.nih.gov/snp/organisms/human_9606/database/organism_data/OmimVarLocusIdSNP.bcp.gz
	gunzip $(CACHEDIR)/OmimVarLocusIdSNP.bcp.gz
morbidmap:
	cd $(CACHEDIR) && wget ftp://ftp.ncbi.nih.gov/repository/OMIM/morbidmap

GETEVIDENCEHOST?=evidence.personalgenomes.org
TRAITOMATICHOST?=snp.oxf.freelogy.org
PID:=$(shell echo $$PPID)

dump_database:
	./dump_database.php public_html/get-evidence.sql.gz

vis_data_local: latest_flat_tmp_local latest_flat latest_flat.gz vis_data
vis_data_http: latest_flat_tmp_http latest_flat latest_flat.gz vis_data
latest_flat_tmp_local:
	mkdir -p $(CACHEDIR)
	(cd public_html && php ./download.php latest flat) > $(CACHEDIR)/latest-flat.tsv.tmp
latest_flat_tmp_http:
	mkdir -p $(CACHEDIR)
	wget -O$(CACHEDIR)/latest-flat.tsv.tmp http://$(GETEVIDENCEHOST)/latest-flat.tsv
latest_flat:
	mv $(CACHEDIR)/latest-flat.tsv.tmp public_html/latest-flat.tsv
latest_flat.gz: latest_flat
	gzip -9n <public_html/latest-flat.tsv >public_html/latest-flat.tsv.gz
vis_data:
	cd get_evidence_vis && ./ProcessTableForVis.pl ../public_html/latest-flat.tsv nsSNP-freq.gff >../public_html/latest_vis_data.tsv.tmp
	cd public_html && mv latest_vis_data.tsv.tmp latest_vis_data.tsv
