<?php
$uptime = shell_exec("cut -d. -f1 /proc/uptime");
$days = floor($uptime/60/60/24);
$hours = $uptime/60/60%24;
$mins = $uptime/60%60;
$secs = $uptime%60;
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
                <h2><?php echo exec('hostname -f')." - ".exec('uname -s -p -r'); ?></h2>
                <h3>PHP <?php echo phpversion(); ?></h3>
            </div>
        </div>
        <div class="container-fluid">
            <div class="table-responsive">
                <table class="table table-condensed">
                    <thead>
                        <th colspan=2 class="text-center">PHP Loaded Extentions</th>
                    </thead>
                    <tbody>
<?php
for ($i = 0; $i < $count; $i++) {
    if (isset($array[$i])) {
        echo "<tr><td><b>{$array[$i]}</b> ".phpversion($array[$i])."</td>";
    }
    $i++;
    if (isset($array[$i])) {
        echo "<td><b>{$array[$i]}</b> ".phpversion($array[$i])."</td></tr>";
    }
}
?>
                    </tbody>
                </table>
            </div>
         </div>
         <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
    </body>
</html>
