class ExerciseTemplate {
  final String name;
  final String description;
  final String muscleGroup;

  const ExerciseTemplate({required this.name, required this.description, required this.muscleGroup});
}

/// Curated exercise list per muscle group. All movements are upper-body
/// or core-stabilized, since the wearable's wrist + torso sensors can
/// only track this range of motion.
class ExerciseDatabase {
  ExerciseDatabase._();

  static const Map<String, List<ExerciseTemplate>> byMuscleGroup = {
    'Biceps': [
      ExerciseTemplate(name: 'Dumbbell Bicep Curl', description: 'Curl dumbbells with controlled tempo, avoid swinging.', muscleGroup: 'Biceps'),
      ExerciseTemplate(name: 'Hammer Curl', description: 'Neutral grip curl targeting the brachialis and forearm.', muscleGroup: 'Biceps'),
      ExerciseTemplate(name: 'Concentration Curl', description: 'Seated single-arm curl for peak contraction.', muscleGroup: 'Biceps'),
      ExerciseTemplate(name: 'Preacher Curl', description: 'Arm braced on a pad to isolate the bicep.', muscleGroup: 'Biceps'),
    ],
    'Chest': [
      ExerciseTemplate(name: 'Push-Up', description: 'Bodyweight press, keep core tight and elbows at 45°.', muscleGroup: 'Chest'),
      ExerciseTemplate(name: 'Dumbbell Bench Press', description: 'Press dumbbells from chest level with a controlled descent.', muscleGroup: 'Chest'),
      ExerciseTemplate(name: 'Chest Fly', description: 'Wide arc motion to stretch and contract the chest.', muscleGroup: 'Chest'),
      ExerciseTemplate(name: 'Incline Push-Up', description: 'Elevated hands to emphasize the upper chest.', muscleGroup: 'Chest'),
    ],
    'Shoulders': [
      ExerciseTemplate(name: 'Overhead Press', description: 'Press weight overhead, avoid excessive lower back arch.', muscleGroup: 'Shoulders'),
      ExerciseTemplate(name: 'Lateral Raise', description: 'Raise arms to shoulder height for side deltoid isolation.', muscleGroup: 'Shoulders'),
      ExerciseTemplate(name: 'Front Raise', description: 'Raise weight forward to shoulder height.', muscleGroup: 'Shoulders'),
      ExerciseTemplate(name: 'Reverse Fly', description: 'Bent-over raise targeting the rear deltoids.', muscleGroup: 'Shoulders'),
    ],
    'Back': [
      ExerciseTemplate(name: 'Bent-Over Row', description: 'Hinge at the hips, row weight to the torso keeping the back flat.', muscleGroup: 'Back'),
      ExerciseTemplate(name: 'Superman Hold', description: 'Bodyweight lower-back and posture activation.', muscleGroup: 'Back'),
      ExerciseTemplate(name: 'Reverse Snow Angel', description: 'Scapular retraction drill for the upper back.', muscleGroup: 'Back'),
      ExerciseTemplate(name: 'Single-Arm Row', description: 'Unilateral row braced on a stable surface.', muscleGroup: 'Back'),
    ],
  };
}