<!DOCTYPE html>
<html lang="fr">
    <head>
        <title><?php echo exec('hostname -f'); ?></title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="author" content="Pascal A.">
        <meta name="generator" content="vim">
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
        <link href="//netdna.bootstrapcdn.com/twitter-bootstrap/2.2.1/css/bootstrap-combined.min.css" rel="stylesheet">
        <style>
            body {
                padding-top: 60px; /* 60px to make the container go all the way to the bottom of the topbar */
            }
        </style>
        <!-- Le HTML5 shim, for IE6-8 support of HTML5 elements -->
        <!--[if lt IE 9]>
        <script src="//html5shim.googlecode.com/svn/trunk/html5.js"></script>
        <![endif]-->
    </head>
    <body>
        <div class="container">
            <div class="page-header">
                <h1 class="pagination-centered">Current PHP version: <?php echo phpversion(); ?> on <i> <?php echo exec('hostname -f'); ?></i></h1>
            </div>

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

            <div class="hero-unit">
                <h2>PHP Loaded Extentions </h2>
                <?php
                echo "<ul>";
                for ($i = 0; $i < $count; $i++) {
                    echo "<li>{$array[$i]} ".phpversion($array[$i])."</li>";
                }
                echo "</ul>";
                ?>
            </div>
        </div>
        <script src="//netdna.bootstrapcdn.com/twitter-bootstrap/2.2.1/js/bootstrap.min.js"></script>
    </body>
</html>
