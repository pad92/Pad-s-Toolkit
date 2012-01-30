<!doctype html>
<html>
<head>
<title><?php echo exec('hostname -f'); ?></title>
<meta charset="utf-8" />
</head>
<body>
<?php
function arraytolower($array,$round = 0){
    foreach($array as $key => $value){
        if(is_array($value)) $array[strtolower($key)] =  $this->arraytolower($value,$round+1);
        else $array[strtolower($key)] = strtolower($value);
    }
    return $array;
}

echo '<p>Current PHP version: <u>'.phpversion().'</u> on <b>'.exec('hostname -f')."</b>";

$array = get_loaded_extensions();
$array = arraytolower($array);
sort($array);
$count = count($array);

echo "<p>PHP Loaded Extentions :</p><ul>";
for ($i = 0; $i < $count; $i++) {
    echo "<li>{$array[$i]}</li>";
}
echo "</ul></p>";
?>
</body>
</html>
