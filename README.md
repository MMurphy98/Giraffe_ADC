# Giraffe ADC

记录存放 ***Giraffe*** 测试的 `Verilog` 代码 与 数据后处理的 `MATLAB` 代码；

## Verilog 

作为片上ADC与主机电脑之间的桥梁，接收ADC发出的`ack` 以及 `Dout_adc[5:0]`信号，并通过串口的方式传输给主机电脑，同时需要给ADC控制信号——`nrst, adc_ena, calib_ena`；


## MATLAB

建立串口Serial实例，从串口中读取数据并直接进行后处理；