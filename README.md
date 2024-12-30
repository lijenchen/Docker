==================================================
(=檔案對應=)
    [=>]詳細完整
    Dockerfile.under
    [=>]內嵌shell
    Dockerfile.under.ubuntu.22  [=>]基底使用ubuntu
    Dockerfile.under.ubuntu.18
    Dockerfile.under.poky.22    [=>]基底使用crops/poky
    [=>]外掛shell
    Dockerfile.above.ubuntu.24
    Dockerfile.above.ubuntu.22
    Dockerfile.above.ubuntu.18
    Dockerfile.above.ubuntu.16
    Dockerfile.above.poky.22
    Dockerfile.above.poky.18

    docker.dumb.sh              [=>]帳號對應腳本(模擬環境使用)
    dockersetup_brain.sh        [=>]帳號對應腳本(Dockerfile使用)

    dockertools_build.sh        [=>]建立對應映像
    dockertools_dpkg.sh         [=>]映像套件資訊

==================================================
(=適用情景=)
[18]  Android       (All)
      Yocto         (All)
      Ubuntu        [!]   (mtk)[kernel] [=>] echo 10 > debian/compat

[22]  Android       (mtk)
      Yocto         (mtk)
      Ubuntu        (mtk)

==================================================
(=參數說明=)
[note][標準]
-d              背景運行
--privileged    特權模式
--device        掛載裝置
--add-host      對照表(hosts)
--dns           運行DNS
--ip            運行IP
--expose        溝通PORT
--hostname	    運行名稱
--entrypoint    複寫設定

[note][標準][常用]
-w              指定工作目錄
-v              掛載指定目錄/檔案
-e              全域變數
--name          模擬環境別名
--rm            離線清除
-it             交互運行

指定工作目錄    => [-v /home/$whoami]
掛載個人目錄    => [-v /home/$whoami:/home/$whoami]
掛載特定目錄    => [-v /home/swshare:/home/swshare]
校正時區        => [-v /etc/localtime:/etc/localtime:ro]
對應(DNS)       => [-v /etc/hosts:/etc/hosts]

[note][私有]
-e IDSET        登入名稱(sw)
-e IDNON        不使用對應(root)

特定名稱登入    => [-e IDSET=welkin]
不用對應登入    => [-e IDNON=1]

==================================================
(=運行環境=)
[note][單一編譯]#[單對單連線]
(方法1) 對應模擬環境
IN=poky18; docker run --rm -it -v /home/$(whoami):/home/$(whoami) -w /home/$(whoami) -e IDSET=$(whoami) --name $(whoami) ${IN} bash

(方法2) 預設模擬環境
IN=poky18; docker run --rm -it -v /home/$(whoami):/home/$(whoami) -w /home/$(whoami) --name $(whoami) ${IN} bash
等同
IN=poky18; docker run --rm -it -v /home/$(whoami):/home/$(whoami) -w /home/$(whoami) -e IDSET=sw --name $(whoami) ${IN} bash


[note][多重編譯]#[單對多連線]
(方法1) 開啟多個模擬環境
IN=poky18; docker run --rm -it -v /home/$(whoami):/home/$(whoami) -w /home/$(whoami) -e IDSET=$(whoami) --name $(whoami).1 ${IN} bash
IN=poky18; docker run --rm -it -v /home/$(whoami):/home/$(whoami) -w /home/$(whoami) -e IDSET=$(whoami) --name $(whoami).2 ${IN} bash
IN=poky18; docker run --rm -it -v /home/$(whoami):/home/$(whoami) -w /home/$(whoami) -e IDSET=$(whoami) --name $(whoami).3 ${IN} bash

(方法2) 開啟單一模擬環境
IN=poky18; docker run -d -it -v /home/$(whoami):/home/$(whoami) -w /home/$(whoami) -e IDSET=$(whoami) --name $(whoami) ${IN} bash
docker exec -it $(whoami)xx bash
docker exec -it $(whoami)xx bash
(p.s.)
使用 --rm 參數開啟的首個連線關閉後，其餘的連線將自動結束，因此改用背景執行方式，使用 -d 替代 --rm
(p.s.)
檢查背景是否存在模擬環境
docker inspect $(whoami)

==================================================