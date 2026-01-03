# Умножение частот

В этом посте поговорим об умножении частоты прямоугольных сигналов на 2.

In this post, multiplication of signal frequencies by 2 is discussed.

В цифровой схемотехнике, когда нужен clk с частотой ниже имеющейся, часто используют счётчик в качестве преобразователя. Так можно частоту поделить на 2 в степени, равной разрядности счётчика. Однако, этот способ не даёт возможности увеличить частоту сигнала. Для этого сигнал удвоенной частоты должен переключаться не только при изменении входного сигнала, но и в момент, когда все сигналы постоянны.

In digital design, when clk of lower frequency than existing, is required, a counter is often used as a converter. In this way, the frequency can be divided by 2 in the power of the width of the counter. However, the frequency can't be increased in this way. To do this, the signal of the increased frequency is required to change not only with changing of the input one, but also in time when all signals are constant.

![](../media/task.svg)

В ПЛИС (например, Altera Cyclone IV, как на схеме ниже) в этом случае используют аналоговые блоки автоподстройки частоты – PLL. Это большие схемы, в которых генератором управляют через отрицательную обратную связь.

In FPGA (for example, Altera Cyclone IV, as on the scheme below) in the case analog blocks called PLL (phase-locked loop) are used. These ones are complex circuits, in which oscillator is controlled with negative feedback.  

![](../media/pll.png)

Реализовать умножение частоты на 2, на самом деле, значительно проще. Достаточно сместить исходный сигнал clk на четверть периода. Далее можно использовать комбинационную логику.

Actually, the realisation of the frequency multiplication by 2 can be done in a significantly simpler way. It's enough to shift the original clk signal by a quarter of the period. After that, a common combinational logic can be used.

![](../media/how_to.svg)

Как видим, нужно выполнить XOR между исходным и смещённым сигналами.

One can see that the logic operation between the original clk and the shifted one is XOR.

Остаётся аналоговая часть: как сдвинуть сигнал на четверть периода?

But the analog part remains: how to shift a signal by a quarter of the period?

Как вариант - RC-цепью внести задержку распространения. Возможно, это первый вариант, который придет в голову. Основной недостаток - величина задержки зависит от R и C, но не от частоты исходного сигнала. То есть, нужно или менять номиналы подключением или отключением резисторов/конденсаторов, или использовать управляемые элементы (например, транзисторы вместо резисторов).

As an option, a propagation delay can be added using an RC-circuit. It's maybe the first option come in one's head, The main fault of the way is that the delay depends on R and C, but not on the input frequency. This means, it is required either to change the values by connecting and disconnecting resistors/capacitors or use controlled components (such as transistors instead of common resistors).

Второй вариант от частоты зависит значительно меньше: нужно выделить треугольный сигнал, который будет повышаться, когда на входе 1, и понижаться, когда 0. Соответственно, на выход нужно подавать 1, когда величина сигнала больше его среднего значения.

The another way provides much lower dependence on the input frequency: the triangle signal should be defined, that would increase, when it's 1 on the input, and decrease, when it's 0. Respectively, 1 should be put on the output, when the value of the signal is bigger than it's average.

![](../media/analog_triangle.svg)

Реализуется треугольный сигнал, на самом деле, той же RC-цепочкой. Переходные процессы в ней экспоненциальные, асимметричные. Из-за этого цифровой сигнал, полученный с неё по сформулированному условию, тоже будет асимметричным (длительность 1 и 0 будут отличаться), что может быть нежелательно. Для устранения этого эффекта нужно выбирать номиналы так, чтобы время релаксации RC было значительно меньше периода, или просто заменить резистор на источник тока, то есть, транзистор. 

Actually, the triangle signal can be implemented with same RC-circuit. The transitions are exponential and asymmetric in it. Because of this, the digital signal obtained from the circuit by the rule above would be asymmetric too (the duration of 1 and 0 would be different), that can be unwanted. To compensate such effect, the values should be chosen so that the relaxation time RC was much less than the period of the signal, or just replace the resistor with a current source, i.e. transistor. 

![](../media/structure.svg)

Достаточно удобно использовать второй вариант. Интегральные транзисторы значительно компактнее резисторов больших номиналов. Правда, конденсатор нужно как заряжать, так и разряжать. Для этого вместо обычного транзистора можно использовать приоткрытый проходной ключ. Так схема будет заряжаться и разряжаться одинаково и, если не линейно, то по крайней мере, не экспоненциально.

It's enough comfortable to implement the second variant. The integral transistors are significantly smaller than high-value resistors. However, the capacitor should be either charged or discharged. In this case a particulary-opened transmission gate may be used. So, the processes would be more symmetric and, if not linear, then, at least, not exponential.
