# Giraffe ADC

记录存放 ***Giraffe*** 测试的 `Verilog` 控制代码；

## Verilog 

作为片上ADC与主机电脑之间的桥梁，接收ADC发出的`ack` 以及 `Dout_adc[5:0]`信号，并通过串口的方式传输给主机电脑，同时需要给ADC控制信号——`nrst, adc_ena, calib_ena`；


## Branches

- `master`： 完成了**低速ADC**数据的接收验证工作，UART工作模式为**连续读写模式**，并且没有限制读写个数；
- `New`： 完成了低速ADC的数据接收工作，UART工作模式为**先读后写模式**，即接收到ADC数据时先往片上MEMORY中写入数据，并设置读写个数，再从MEMORY中读出数据发送；
  
    - 使用片上PLL IP驱动时钟输出端口，由`my_PLL.v`文件创建实例，输出时钟速度由`altpll_component.clk0_divide_by`确定，目前为5000，即输出时钟为10kHz；
  
    - ADC的使能信号工作模式为**计数输出模式**， 即`adc_ena`信号不由`adc_ack`信号触发，而是对`clk_adc`时钟计数完成，由计数器`cnt_ena_period`控制，目前为**50*clk_adc**触发1次采样；

    - 添加了对输入输出IO的constrain，由`Giraffe_ADC_qsf`文件控制；


## TODO

- [ ] 修改ADC信号的触发逻辑，以便于高速ADC性能测试；
- [ ] 添加代码注释；



