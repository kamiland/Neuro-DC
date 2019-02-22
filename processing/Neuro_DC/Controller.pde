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
