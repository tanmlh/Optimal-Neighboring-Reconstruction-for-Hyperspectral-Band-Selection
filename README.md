## Optimal Neighboring Reconstruction for Hyperspectral Band Selection

This repo provides a Matlab implementation of the conference paper "Optimal Neighboring Reconstruction for Hyperspectral Band Selection, IGARSS 2018".

File 'demo.m' shows a simple and direct way to run the ONR algorithm. 

File 'evaluation.m' provides an easily extended framework to evaluate different band selection methods on different datasets. One can get a accuracy curve by running 'evaluation.m'.

Note that in order to successfully run 'evaluation.m', Libsvm for Matlab should be installed at first.
If you want to evaluate the algorithm on datasets other than Indian Pines, they should also be downloaded in advance.

Link for Libsvm: [https://www.csie.ntu.edu.tw/~cjlin/libsvm/](https://www.csie.ntu.edu.tw/~cjlin/libsvm/)

Link for labeled hyperspectral image datasets: [http://www.ehu.eus/ccwintco/index.php/Hyperspectral_Remote_Sensing_Scenes](http://www.ehu.eus/ccwintco/index.php/Hyperspectral_Remote_Sensing_Scenes)

### Results
<center>
<img src="fig/1.png" width='40%' height='35%' />
<img src="fig/2.png" width='40%' height='35%' />
Indian Pines Dataset
</center>

<center>
<img src="fig/3.png" width='40%' height='35%' />
<img src="fig/4.png" width='40%' height='35%' />
Pavia University Dataset
</center>

<center>
<img src="fig/5.png" width='40%' height='35%' />
<img src="fig/6.png" width='40%' height='35%' />
Salinas Dataset
</center>

<center>
<img src="fig/7.png" width='40%' height='35%' />
<img src="fig/8.png" width='40%' height='35%' />
KSC Dataset
</center>

<center>
<img src="fig/9.png" width='40%' height='35%' />
<img src="fig/10.png" width='40%' height='35%' />
Botswana Dataset
</center>