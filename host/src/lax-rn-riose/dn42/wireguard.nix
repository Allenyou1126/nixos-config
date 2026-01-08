{ config, lib, pkgs, modulesPath, ... }:

let
in {
    services.dn42.wireguard = {
        enable = true;
        local = {
            addressV4 = "172.21.89.225/27";
            addressV6 = "fdbf:b830:8a32::1/64";
            localLinkAddressV6 = "fe80::1056/64";
            privateKeyFile = config.age.secrets.wireguardPrivateKeyFile.path;
        };
        staticSessions = {
            hkg-dog-darell = {
                addressV4 = "172.21.89.226/32";
                addressV6 = "fdbf:b830:8a32::2/128";
                publicKey = "QNl4r/O/NDty0SIEc3yItWskSQS7/tHcIveCM6rrCwI=";
                listenPort = 50226;
                endpoint = "hkg-dog-darell.server.allenyou.wang:50225";
            };
        };
        dn42PeeringSessions = {
            # akix = {
            #     addressV4 = "172.20.183.3";
            #     addressV6 = "fd15:9c81:b912::1/128";
            #     localLinkAddressV6 = "fe80::616b:6978/64";
            #     endpoint = "ixp.akae.re:21056";
            #     publicKey = "vFfgy5SyzrEeqouotHv3IpAh+aL3OBqGf/jrziz5WyA=";
            #     listenPort = 10440;
            # };
            # morecake = {
            #     localLinkAddressV6 = "fe80::1118";
            #     endpoint = "jp.dn42.ainic.ee:21056";
            #     publicKey = "2UHctxbyqTaY/cTiXDfSz8h+uJEluqYeeHQzzY9+aU4=";
            #     listenPort = 21118;
            # };
            darkpoint = {
                localLinkAddressV6 = "fe80::150";
                endpoint = "iad.darkpoint.xyz:21056";
                publicKey = "1o0XfQvBM1gqknqzfuOnVmf2RjRTHuyMZYNipSSb2TQ=";
                listenPort = 20150;
            };
            lantian = {
                addressV4 = "172.22.76.185";
                addressV6 = "fdbc:f9dc:67ad:3::1";
                localLinkAddressV6 = "fe80::2547";
                endpoint = "v4.v-ps-sjc.lantian.pub:21056";
                publicKey = "zyATu8FW392WFFNAz7ZH6+4TUutEYEooPPirwcoIiXo=";
                listenPort = 22547;
            };
            duststars = {
                addressV6 = "fe80::afaf:bfbf:cdcf:7";
                endpoint = "lax1.exploro.one:32591";
                publicKey = "+SESp7mO2U1EEXKgBlgWr7DLi6rejUb5ZMZBuBXtsDU=";
                listenPort = 21771;
            };
            lezi = {
                addressV4 = "172.22.137.98";
                addressV6 = "fdb6:fc6a:e66c::2";
                localLinkAddressV6 = "fe80::3377";
                endpoint = "los1-us.peer.dn42.leziblog.com:21056";
                publicKey = "Xzt9UrH2moj84QSH0jsw8Zj+jwXwdBLpApe4hHyfnAw=";
                listenPort = 23377;
            };
            potat0 = {
                addressV4 = "172.23.246.3";
                addressV6 = "fd2c:1323:4042::3";
                localLinkAddressV6 = "fe80::1816";
                endpoint = "las.node.potat0.cc:21056";
                publicKey = "LUwqKS6QrCPv510Pwt1eAIiHACYDsbMjrkrbGTJfviU=";
                listenPort = 21816;
            };
            h503mc = {
                localLinkAddressV6 = "fe80::298";
                endpoint = "node3.ox5.cc:21056";
                publicKey = "iKpHMLkks7SHpwVwsGVkBL5IDRswqY6zTHBRZiDQpVo=";
                preSharedKeyFile = config.age.secrets.h503mc-Dn42WireguardPresharedKeyFile.path;
                listenPort = 20298;
            };
            limont = {
                addressV4 = "172.20.5.65";
                addressV6 = "fd9f:3222:a7b7::1";
                localLinkAddressV6 = "fe80::88:2";
                endpoint = "us01-peer.furry.lv:21056";
                publicKey = "YjnCVWBsTBoslPqJ88ao+bzHsDFj2BezVW5qrvcLtiE=";
                listenPort = 20088;
            };
            prefixlabs = {
                localLinkAddressV6 = "fe80::1240:3";
                endpoint = "us-02.prefixlabs.net:21056";
                publicKey = "+NrpWdvnG57iyu5nNUMRLlMGAScyibhjGy1Ev4NbhgI=";
                listenPort = 21240;
            };
            littlecow = {
                addressV4 = "172.22.144.66";
                addressV6 = "fd36:62be:ef51:2::1";
                localLinkAddressV6 = "fe80::2:3999";
                endpoint = "lax.node.cowgl.xyz:31056";
                publicKey = "jhOukGNAKHI8Ivn8uI1TS25n5ho/rVlKFfenGmwCVlg=";
                listenPort = 23999;
            };
            sunnet = {
                addressV4 = "172.21.100.193";
                addressV6 = "fdc8:dc88:ee11:193::1";
                endpoint = "lax1-us.dn42.6700.cc:21056";
                publicKey = "QSAeFPotqFpF6fFe3CMrMjrpS5AL54AxWY2w1+Ot2Bo=";
                listenPort = 23088;
            };
            kemono42 = {
                addressV4 = "172.21.82.129";
                addressV6 = "fe80::358/64";
                endpoint = "sjc.us.dn42.kemonos.net:20358";
                publicKey = "7HzHyeA2M7yo/zVmc+e0zG+I7j2SnIx+7ZpXOca93mg=";
                listenPort = 20358;
            };
            wolfyf = {
                addressV4 = "172.21.104.33";
                addressV6 = "fd3b:ed51:c993::1";
                localLinkAddressV6 = "fe80::2034";
                endpoint = "v1.932.moe:21056";
                publicKey = "Zl72hWVO9Ib3ylYqKpDCEq8VyiJjY0WDhXP+vX+CzFs=";
                listenPort = 22034;
            };
        };
    };
}