<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <title>服务器状态</title>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/5.3.0/css/bootstrap.min.css" rel="stylesheet">
  <link href="styles.css" rel="stylesheet"> <!-- 外部样式表 -->

  <?php
  // 引入所需的函数和变量定义
  function humanFileSize($size) {
    $units = array('bytes', 'KB', 'MB', 'GB', 'TB');
    $unit = 0;
    while ($size >= 1024 && $unit < count($units) - 1) {
      $size /= 1024;
      $unit++;
    }
    return round($size, 2) . ' ' . $units[$unit];
  }

  function getProgressBarColor($percentage) {
    if ($percentage >= 90) {
      return 'bg-danger';
    } elseif ($percentage >= 75) {
      return 'bg-warning';
    } else {
      return 'bg-success';
    }
  }
  ?>
</head>

<body>
  <div class="container">
    <h1>服务器状态</h1>
    <hr />

    <?php
    function fetchServerStatus($key, $hash, $url, $beizhu) {
      $postfields = array(
        "key" => $key,
        "hash" => $hash,
        "action" => "info",
        "status" => "true",
        "hdd" => "true",
        "mem" => "true",
        "bw" => "true",
        "ipaddr" => "true"
      );

      $ch = curl_init();
      curl_setopt_array($ch, array(
        CURLOPT_URL => "{$url}/api/client/command.php",
        CURLOPT_POST => 1,
        CURLOPT_RETURNTRANSFER => 1,
        CURLOPT_POSTFIELDS => $postfields,
        CURLOPT_HTTPHEADER => array("Expect: "),
        CURLOPT_SSL_VERIFYPEER => 0,
        CURLOPT_SSL_VERIFYHOST => 0
      ));

      $data = curl_exec($ch);
      $code = curl_getinfo($ch, CURLINFO_HTTP_CODE);
      curl_close($ch);

      if ($code != 200 || !$data) {
        return array("error" => 1, "message" => ($code == 405) ? "API凭据不正确。" : "连接API时出错。");
      }

      $result = array("bz" => $beizhu);

      preg_match_all('/<(.*?)>([^<]+)<\/\\1>/i', $data, $match);
      foreach ($match[1] as $x => $y) {
        $result[$y] = $match[2][$x];
      }

      preg_match('/<ipaddr>([^<]+)<\/ipaddr>/i', $data, $ip_match);
      $result['ipaddr'] = $ip_match[1];

      if ($result['status'] == "error") {
        return array("error" => 1, "message" => $result['statusmsg']);
      }

      $result['hdd'] = explode(",", $result['hdd']);
      $result['mem'] = explode(",", $result['mem']);
      $result['bw'] = explode(",", $result['bw']);

      $result['error'] = 0;
      return $result;
    }

    $serverConfigs = array(
      array(getenv('API_KEY'), getenv('API_HASH'), getenv('API_URL'), "服务器 1"),
      // 可添加更多服务器配置
    );

    $serverStatuses = array();
    foreach ($serverConfigs as $config) {
      $serverStatuses[] = fetchServerStatus($config[0], $config[1], $config[2], $config[3]);
    }
    ?>

    <table class="table table-striped">
      <thead>
        <tr>
          <th>IP 地址</th>
          <th>带宽</th>
          <th>内存</th>
          <th>磁盘</th>
        </tr>
      </thead>
      <tbody>
        <?php foreach ($serverStatuses as $status) { ?>
          <tr>
            <td><?php echo htmlspecialchars($status['ipaddr']); ?></td>
            <?php foreach (['bw', 'mem', 'hdd'] as $type) { ?>
              <td>
                <div class="progress">
                  <?php
                  $percentage = $status[$type][3];
                  $bg_class = getProgressBarColor($percentage);
                  ?>
                  <div class="progress-bar <?php echo $bg_class; ?>" role="progressbar" style="width: <?php echo $percentage; ?>%;" aria-valuenow="<?php echo $percentage; ?>" aria-valuemin="0" aria-valuemax="100">
                    <?php echo $percentage; ?>%
                  </div>
                </div>
                <small>已用 <?php echo humanFileSize($status[$type][1]); ?> / 总量 <?php echo humanFileSize($status[$type][0]); ?></small>
              </td>
            <?php } ?>
          </tr>
        <?php } ?>
      </tbody>
    </table>
  </div>
</body>
</html>
