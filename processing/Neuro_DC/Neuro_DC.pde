import grafica.*;

public class Solver
{
  /** U - napięcie zasilania, E - siła elektromotoryczna */
  double U, E;
  /** La - indukcyjność własna wirnika, Ra - rezystancja uzwojenia wirnika, Ua - napięcie twornika    */
  public double La, Ra, Ua;
  /** Lf - indukcyjność własna obwodu wzbudzenia, Rf - rezystancja obwodu wzbudzenia, If - prąd obwodu wzbudzenia     */
  public double Lf, Rf, If, Ufn;
  /** Laf - indukcyjność wzajemna   */
  public double Laf;
  /**  T - moment napędowy, B - współczynnik tłumienia, p - pary biegunów, Tl - moment obciążenia, J - moment bezwłądności */
  public double T, B, p, Tl, J;
  /** Stała obwodu wzbudzenia (stałe magnesowanie) ifn = Ufn / Rf */
  double ifn;
  /** prędkość kątowa, prąd obwodu wirnika */
  double angularVelocity, rotorCurrent;

  double Gaf;

  public double[] x = new double[2];

  public Solver()
  {
    /** Parametry domyślne  */
    Ra = 0.4;   
    La = 0.02;
    Rf = 65;    
    Lf = 65;
    J = 0.11; 
    B = 0.0053;
    p = 2;
    Laf = 0.363;
    Ufn = 110;

    /** Wartości początkowe dla obiektu silnika   */
    rotorCurrent = 0; 
    angularVelocity = 0; 
    x[0] = rotorCurrent;
    x[1] = angularVelocity;

    ifn = Ufn / Rf;
    Gaf = p * Laf * ifn;
    E = Gaf * angularVelocity;
    T = Gaf * rotorCurrent;
  }


  public double calculateRotorCurrent(double x1, double x2, double U)
  {
    return -(Ra / La) * x1 - (Gaf / La) * x2 + (1 / La) * U;
  }


  public double calculateAngularVelocity(double x1, double x2, double Tl)
  {
    return (Gaf / J) * x1 - (B / J) * x2 + (1 / J) * Tl;
  }

  // implementacja algorytmu Rungego-Kutty dla obiektu silnika DC (https://pl.wikipedia.org/wiki/Algorytm_Rungego-Kutty)
  public double[] CalculateNextStep(double U, double h)
  {
    double[][] k = new double[2][4];

    /** Wyznaczanie prądu obwodu wirnika    */
    k[0][0] = h * calculateRotorCurrent(x[0], x[1], U);
    k[0][1] = h * calculateRotorCurrent(x[0] + k[0][0] / 2, x[1] + k[0][0] / 2, U);
    k[0][2] = h * calculateRotorCurrent(x[0] + k[0][1] / 2, x[1] + k[0][1] / 2, U);
    k[0][3] = h * calculateRotorCurrent(x[0] + k[0][2], x[1] + k[0][2], U);

    /** Wyznaczanie prędkości kątowej */
    k[1][0] = h * calculateAngularVelocity(x[0], x[1], 0);
    k[1][1] = h * calculateAngularVelocity(x[0] + k[1][0] / 2, x[1] + k[1][0] / 2, 0);
    k[1][2] = h * calculateAngularVelocity(x[0] + k[1][1] / 2, x[1] + k[1][1] / 2, 0);
    k[1][3] = h * calculateAngularVelocity(x[0] + k[1][2], x[1] + k[1][2], 0);

    for (int i = 0; i < 2; i++)
    {
      x[i] = x[i] + (k[i][0] + 2 * k[i][1] + 2 * k[i][2] + k[i][3]) / 6;
    }
    return x;
  }
}

public class Controller
{
  public double Kp, Ki, Kd;
  double P, I, D;
  double integral, derivative;
  double error, preError = 0, controllerOutput = 0;
  final int maxOutput = 230;
  final int minOutput = 0;

  public Controller(double initialKp, double initialKi, double initialKd)
  {
    Kp = initialKp;
    Ki = initialKi;
    Kd = initialKd;
  }

  public double CalculateOutput(double setpoint, double pv, double dt)
  {
    error = setpoint - pv;

    P = Kp * error;

    integral += error * dt;
    I = Ki * integral;

    derivative = (error - preError) / dt;
    D = Kd * derivative;

    preError = error;

    controllerOutput = P + I + D;
    if (controllerOutput > maxOutput) controllerOutput = maxOutput;
    if (controllerOutput < minOutput) controllerOutput = minOutput;

    return controllerOutput;
  }
}

public class Simulator
{
  public Controller PID = new Controller(5, 0.2, 0.001);
  public Solver RK4 = new Solver();
  double setpoint = 150;
  final double PIDtimeStep = 0.001; 
  
  
  
  //public double fitness = 0;
  //double error_int = 0;


  public double[] Simulate(long numberOfProbes, double timeStep, GPointsArray points)
  {
   //GPointsArray points = new GPointsArray((int)numberOfProbes);
    RK4.x[0] = 0;
    RK4.x[1] = 0;

    //wykonaj liczbe kroków określoną w numberOfProbes, zapisz pomiary do plików, oblicz całkę uchybu 
    for (int i = 0; i < numberOfProbes; i++)
    {
      RK4.x = RK4.CalculateNextStep(PID.CalculateOutput(setpoint, RK4.x[1], PIDtimeStep), timeStep);
      
      points.add(i,(int) RK4.x[1]);
      //error_int += (Math.Abs(setpoint - RK4.x[1])) * timeStep;
    }

    //fitness = 1.0 / (error_int + 1.0);
    return RK4.x;
  }
}

void setup() {
  size(500, 350);
  background(150);

  Simulator simulatorDC = new Simulator();
  long numberOfProbes = 1000;
  double timeStep = 0.001;

  // Prepare the points for the plot
  int nPoints = 1000;
  GPointsArray points = new GPointsArray(nPoints);

  simulatorDC.Simulate(numberOfProbes, timeStep, points);

  //for (int i = 0; i < nPoints; i++) {
  //  points.add(i, 10*noise(0.1*i));
  //}

  // Create a new plot and set its position on the screen
  GPlot plot = new GPlot(this);
  plot.setPos(25, 25);
  // or all in one go
  // GPlot plot = new GPlot(this, 25, 25);

  // Set the plot title and the axis labels
  plot.setTitleText("A very simple example");
  plot.getXAxis().setAxisLabelText("x axis");
  plot.getYAxis().setAxisLabelText("y axis");

  // Add the points
  plot.setPoints(points);

  // Draw it!
  plot.defaultDraw();
}

void draw()
{
}
