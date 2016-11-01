function barPlotSegmentationQuality()

vrand_rfc = 0.709217206156398;
vinfo_rfc = 0.8648780703061639;

vrand_rfc_ilp = 0.8477450799458087;
vinfo_rfc_ilp = 0.9368294433311285;

vrand_cnn = 0.9579670999164946;
vinfo_cnn = 0.9825597349627037;

vrand_cnn_ilp = 0.9738130090973501;
vinfo_cnn_ilp = 0.9840768460979532;


y = [vrand_cnn vrand_cnn_ilp;
    vinfo_cnn vinfo_cnn_ilp;
    vrand_rfc vrand_rfc_ilp;
    vinfo_rfc vinfo_rfc_ilp];

bar(y)

xmin = 0.5;
xmax = 4.5;
ymin = 0.6;
ymax = 1.05;
lims = [xmin xmax ymin ymax];
axis(lims);

set(gca,'XTickLabel',{'CNN:Rand', 'CNN:V\_info','RFC:Rand', 'RFC:V\_info'})
legend('Best threshold', 'After ILP')