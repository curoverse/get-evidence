#!/usr/bin/php
<?php
    ;

chdir ('public_html');
require_once 'lib/setup.php';

ini_set ("output_buffering", FALSE);
ini_set ("memory_limit", 67108864);

$fh = fopen("php://stdout", "a+");

$q = theDb()->query ("
SELECT *
 FROM edits
 LEFT JOIN variants ON edits.variant_id=variants.variant_id
 WHERE is_draft=0 AND article_pmid>0 AND genome_id=0 AND disease_id=0 AND summary_long like '<?xml%'
");
if (theDb()->isError($q)) die ($q->getMessage() . "\n");

$fields = split(' ', 'edit_timestamp edit_oid variant_id variant_gene variant_aa_del variant_aa_pos variant_aa_ins variant_rsid summary_long');
fputcsv($fh, $fields);

$n=0;
while ($row =& $q->fetchRow()) {
    $out = array();
    foreach ($fields as $f) {
	$out[] = $row[$f];
    }
    fputcsv($fh, $out);
}
fclose($fh);
