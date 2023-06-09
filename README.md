# Giraffe ADC

记录存放 ***Giraffe*** 测试的 `Verilog` 控制代码；

## Verilog 

作为片上ADC与主机电脑之间的桥梁，接收ADC发出的`ack, sub_ack` 以及 `Dout_adc[5:0]`信号，并通过串口的方式传输给主机电脑，同时需要给ADC控制信号——`nrst, adc_ena, calib_ena`；


## Branches

- `master`： 完成了**低速ADC**数据的接收验证工作，UART工作模式为**连续读写模式**，并且没有限制读写个数；
- `New`： 完成了低速ADC的数据接收工作，UART工作模式为**先读后写模式**，即接收到ADC数据时先往片上**MEMORY**中写入数据，并设置读写个数，再从**MEMORY**中读出数据发送；
  
    - 使用片上PLL IP驱动时钟输出端口，由`my_PLL.v`文件创建实例，输出时钟速度由`altpll_component.clk0_divide_by`确定，目前为10，即输出时钟为**0.5MHz**；
  
    - ADC的使能信号工作模式为**计数输出模式**， 即`adc_ena`信号不由`adc_ack`信号触发，而是对`clk_adc`时钟计数完成，由计数器`cnt_ena_period`控制，目前为**25*clk_adc**触发1次采样；

    - 添加了对输入输出IO的引脚约束，由`Giraffe_ADC.qsf`文件控制；
    
    - 添加了对输入输出IO的时序约束，由`Giraffe_ADC.out.sdc`文件控制；

- `UART`：在`New`的基础上增加了关于 Inter-stage Amplifier等待时间的控制逻辑，根据**9个Switches**来输出控制电压，控制3次放大的等待时间；



## TODO

- [X] 添加代码注释；
- [x] 校验`input_delay` 和 `output_delay`的逻辑功能是否正确；

## Update Logs
- `20230609`: Merged Branch `New` to `master`, and delete `New`;
- `20230609`: Created Branch `UART` for INL, DNL tests of Giraffe ADC;
- 

