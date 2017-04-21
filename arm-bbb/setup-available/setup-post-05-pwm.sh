#!/bin/bash

echo '/dts-v1/;
/plugin/;

/{
  compatible = "ti,beaglebone", "ti,beaglebone-black";
  
  part-number = "BB-PWM";
  version = "00A0";

  fragment@0 {
    target = <&am33xx_pinmux>;
    __overlay__ {
      pinctrl_spec: ehrpwm_pins {
        pinctrl-single,pins = <
     /*     0x0c8 0x02 */ /* P8_36 MODE2 ehrpwm1A PWM */
     /*     0x0cc 0x02 */ /* P8_34 MODE2 ehrpwm1B PWM */
          0x020 0x04 /* P8_19 MODE4 ehrpwm2A PWM */
          0x024 0x04 /* P8_13 MODE4 ehrpwm2B PWM */
        >;
      };
    };
  };

  fragment@1 {
    target = <&ocp>;
    __overlay__ {
      test_helper: helper {
        compatible = "bone-pinmux-helper";
        pinctrl-names = "default";
        pinctrl-0 = <&pinctrl_spec>;
        status = "okay";
      };
    };
  };
  
  fragment@2 {
    target = <&epwmss1>;
    __overlay__ {
      status = "okay";
    };
  };

  fragment@3 {
    target = <&ehrpwm1>;
    __overlay__ {
      status = "okay";
    };
  };

  fragment@4 {
    target = <&epwmss2>;
    __overlay__ {
      status = "okay";
    };
  };

  fragment@5 {
    target = <&ehrpwm2>;
    __overlay__ {
      status = "okay";
    };
  };
};' > BB-PWM-00A0.dts

dtc -@ -O dtb -o  BB-PWM-00A0.dtbo BB-PWM-00A0.dts

mv BB-PWM-00A0.dtbo /lib/firmware/

echo -e "#!/bin/bash\necho -e 'BB-PWM' > /sys/bus/platform/devices/bone_capemgr/slots" > /root/boot/capemgr-slots-pwm.sh
chmod 755 /root/boot/capemgr-slots-pwm.sh
echo -e "[Unit]\nDescription=Enables the PWM\n\n[Service]\nExecStart=/root/boot/capemgr-slots-pwm.sh\n\n[Install]\nWantedBy=multi-user.target " > /etc/systemd/system/capemgr-slots-pwm.service 

systemctl enable capemgr-slots-pwm.service 

