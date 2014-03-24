<?php
//echo $_SERVER['argv'][1]," -> ", $_SERVER['argv'][2],"\n";

$content = file_get_contents($_SERVER['argv'][1]);
if(preg_match_all("/~~~([^~]+)~~~/", $content, $arr, PREG_SET_ORDER)) {
	$replacements = Array();
	foreach($arr as $a) {
		$var = getenv($a[1]);
		if($var === false) {
			echo 'Unknown place holder ' . $a[0];
			exit(1);
		}
		else {
			$replacements[$a[0]] = $var;
		}
	}
	foreach($replacements as $placeholder => $value) {
		$content = str_replace($placeholder, $value, $content);
	}
}
file_put_contents($_SERVER['argv'][2], $content);
