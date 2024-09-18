import 'dart:math';
import 'Inhalation.dart';

class THCConcentration {
  final double
      absorptionCoefficient; // A: related to depth/duration of inhalation
  final double absorptionRateConstant; // k_a: absorption rate
  final double eliminationRateConstant; // k_e: elimination rate
  final double eliminationPerUnitTime; // B: amount eliminated over time
  List<Inhalation> inhalations; // List of inhalation events (timestamp, length)

  THCConcentration({
    this.absorptionCoefficient = 0.25, // Default 25% absorption
    this.absorptionRateConstant = 0.1 / 60000, // Default absorption rate
    this.eliminationRateConstant = 0.00024 / 60000, // Default elimination rate
    this.eliminationPerUnitTime =
        0.00333 / 60000, // Default elimination per minute
    required this.inhalations,
  });

  double calculateTHCAtTime(double t) {
    double thcConcentration = 0.0;

    for (Inhalation inhalation in inhalations) {
      double inhalationTime = inhalation.time;
      double inhalationDuration = inhalation.duration;

      // Calculate the absorption based on inhalation event
      double absorbedTHC = absorptionCoefficient *
          (1 - exp(-absorptionRateConstant * inhalationDuration));

      // Determine how much THC is left after elimination over time
      double timeSinceInhalation = t - inhalationTime;

      if (timeSinceInhalation > 0) {
        double remainingTHC =
            absorbedTHC * exp(-eliminationRateConstant * timeSinceInhalation);
        thcConcentration += remainingTHC;
      }
    }

    // Ensure the concentration can't be negative
    return thcConcentration > 0 ? thcConcentration : 0.0;
  }
}
