void draw(GPlot[] plot, GPointsArray[] points)
{
  float[] firstPlotPos = new float[] {0, 0};
  float[] panelDim = new float[] {400, 400};
  float[] margins = new float[] {60, 70, 40, 30};

  plot[0].setPos(firstPlotPos);
  plot[0].setMar(0, margins[1], margins[2], 0);
  plot[0].setDim(panelDim);
  plot[0].setAxesOffset(0);
  plot[0].setTicksLength(-4);
  plot[0].getXAxis().setDrawTickLabels(true);

  plot[1].setPos(firstPlotPos[0] + margins[1] + panelDim[0] , firstPlotPos[1]);
  plot[1].setMar(0, 0, margins[2], margins[3]);
  plot[1].setDim(panelDim);
  plot[1].setAxesOffset(0);
  plot[1].setTicksLength(-4);
  plot[1].getXAxis().setDrawTickLabels(true);
  plot[1].getYAxis().setDrawTickLabels(true);

  // Set the points, the title and the axis labels
  plot[0].setPoints(points[0]);
  plot[0].setTitleText("Plot with multiple panels");
  plot[0].getTitle().setRelativePos(1);
  plot[0].getTitle().setTextAlignment(CENTER);
  plot[0].getYAxis().setAxisLabelText("cos(i)");
  plot[1].setPoints(points[1]);

  // Draw the plots
  plot[0].beginDraw();
  plot[0].drawBox();
  plot[0].drawXAxis();
  plot[0].drawYAxis();
  plot[0].drawTopAxis();
  plot[0].drawRightAxis();
  plot[0].drawTitle();
  plot[0].drawPoints();
  plot[0].drawLines();
  plot[0].endDraw();

  plot[1].beginDraw();
  plot[1].drawBox();
  plot[1].drawXAxis();
  plot[1].drawYAxis();
  plot[1].drawTopAxis();
  plot[1].drawRightAxis();
  plot[1].drawPoints();
  plot[1].drawLines();
  plot[1].endDraw();
}
