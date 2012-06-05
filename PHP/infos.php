<html lang="fr">
    <head>
        <meta name="author" content="Alterwat Hosting">
        <meta name="generator" content="vim">
        <meta http-equiv="Content-Type" content="text/html;charset=utf-8" >
    <title><?php echo exec('hostname -f'); ?></title>
    <style>
body {
    color: #FF0099;
    background: #ffddcc;
    font: 300 16px/1.5 "Helvetica Neue", sans-serif;
    font-family: 'Helvetica Neue', sans-serif;
    font-size: 16px;
    font-style: normal;
    font-variant: normal;
    font-weight: 300;
    line-height: 1.5;
    text-align: left;
}
h1, h2 {
    text-shadow: #2E2E2E 1px 1px 1px;
}

h1 {
    font-size: 140%;
}

h2 {
    font-size: 120%;
}

a, a:visited, .disqus-wrapper a, #builder a.selected, #footer a.announcements {
    color: #E16734;
    text-decoration: none;
    text-shadow: 2px 2px 0px black;
}
a:hover, a:focus {
    text-decoration: none;
    color: #E16734;
    text-shadow: 1px 1px 0px black;
}

caption {
    margin: 0.25em auto 0;
    font-size: 18px;
    font-weight: bold;
    text-align: left;
    margin-bottom: 10px;
    text-shadow: 1px 1px 0px black, 2px 2px 0px #434343, 3px 3px 0px #434343;
}
ul, ol {
    margin: 1em 0;
}
ul, menu, dir {
    display: block;
}

.div-table{
    background: #FFFFFF;
    display: table;
    *border-collapse: collapse; /* IE7 and lower */
    border-spacing: 10px;
    margin: 10px auto;
    border-radius: 15px;
    border: 1px solid black;
}
pre, code, kbd, samp {
    font-family: monospace, serif; _font-family: 'courier new', monospace;
    font-size: 0.8em;
    padding: 5px;
    text-align:left;

}
table {
    *border-collapse: collapse; /* IE7 and lower */
    border-spacing: 0;
    margin: 20px auto;
}

    </style>

</head>
<body>

<section id="content" class="body">
        <div class="div-table">
<?php
function arraytolower($array,$round = 0){
   foreach($array as $key => $value){
      if(is_array($value)) $array[strtolower($key)] =  $this->arraytolower($value,$round+1);
      else $array[strtolower($key)] = strtolower($value);
   }
   return $array;
}

echo '<h1>Current PHP version: '.phpversion().' on <i>'.exec('hostname -f')."</i></h1>";

$array = get_loaded_extensions();
$array = arraytolower($array);
sort($array);
$count = count($array);

echo "<h2>PHP Loaded Extentions :</h2><ul>";
for ($i = 0; $i < $count; $i++) {
   echo "<li>{$array[$i]}</li>";
}
echo "</ul></p>";
?>
        </div>
    </section>

</body>
</html>
