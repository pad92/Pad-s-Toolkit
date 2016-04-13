<!DOCTYPE html>
<html lang="fr">
    <head>
        <title><?php echo exec('hostname -f'); ?></title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="author" content="Pascal A.">
        <meta name="generator" content="vim">
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
        <link href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css" rel="stylesheet">
        <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
        <!--[if lt IE 9]>
        <script src="//html5shim.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
    </head>
    <body>
        <div class="container-fluid">
            <div class="page-header">
                <h1 class="pagination-centered">Current PHP version: <?php echo phpversion(); ?> on <i> <?php echo exec('hostname -f'); ?></i></h1>
            </div>
        </div>
        <div class="container-fluid">
<?php
function arraytolower($array,$round = 0){
    foreach($array as $key => $value){
        if(is_array($value)) $array[strtolower($key)] =  $this->arraytolower($value,$round+1);
        else $array[strtolower($key)] = strtolower($value);
    }
    return $array;
}
$array = get_loaded_extensions();
$array = arraytolower($array);
sort($array);
$count = count($array);
?>
<table class="table table-condensed">
    <thead>
        <th colspan=2 class="text-center">PHP Loaded Extentions</th>
    </thead>
    <tbody>
<?php
for ($i = 0; $i < $count; $i++) {
    echo "<tr><td>{$array[$i]} ".phpversion($array[$i])."</td>";
    $i++;
    echo "<td>{$array[$i]} ".phpversion($array[$i])."</td></tr>";
}
?>
    </tbody>
</table>
        </div>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
    </body>
</html>
