//
//  ExerciseData.swift
//  BackWell
//
//  Created by standard on 1/17/26.
//

import Foundation

struct Exercise: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let duration: Int // seconds
    let instructions: [String]
    let icon: String // SF Symbol
    let focusArea: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(duration)
    }

    static func == (lhs: Exercise, rhs: Exercise) -> Bool {
        lhs.name == rhs.name && lhs.duration == rhs.duration
    }
}

struct MentalComponent: Identifiable, Hashable {
    let id = UUID()
    let type: MentalComponentType
    let duration: Int // seconds
    let guidance: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(duration)
    }

    static func == (lhs: MentalComponent, rhs: MentalComponent) -> Bool {
        lhs.type == rhs.type && lhs.duration == rhs.duration
    }
}

enum MentalComponentType: Hashable {
    case breathing
    case affirmation
    case bodyScan
    case reflection
}

struct DayProgram: Identifiable, Hashable {
    let id = UUID()
    let day: Int
    let title: String
    let theme: String
    let mentalFocus: String
    let exercises: [Exercise]
    let mentalComponents: [MentalComponent]
    let completionMessage: String

    func hash(into hasher: inout Hasher) {
        hasher.combine(day)
    }

    static func == (lhs: DayProgram, rhs: DayProgram) -> Bool {
        lhs.day == rhs.day
    }
}

// MARK: - All 28 Days of Content
class ExerciseDatabase {
    static let allDays: [DayProgram] = [
        // WEEK 1: FOUNDATION (Days 1-7) - Gentle Relief & Pain Reduction
        DayProgram(
            day: 1,
            title: "Welcome to Relief",
            theme: "Gentle Introduction",
            mentalFocus: "Beginning Your Journey",
            exercises: [
                Exercise(name: "Deep Breathing", duration: 60, instructions: ["Lie on your back", "Place hands on belly", "Breathe deeply into your abdomen", "Feel your back relax into the floor"], icon: "wind", focusArea: "Relaxation"),
                Exercise(name: "Pelvic Tilts", duration: 45, instructions: ["Lie on back, knees bent", "Gently tilt pelvis up", "Press lower back to floor", "Release slowly"], icon: "figure.flexibility", focusArea: "Lower Back"),
                Exercise(name: "Knee to Chest", duration: 30, instructions: ["Bring one knee toward chest", "Hold gently", "Keep other leg extended", "Switch sides"], icon: "figure.flexibility", focusArea: "Lower Back"),
                Exercise(name: "Cat-Cow Stretch", duration: 45, instructions: ["Start on hands and knees", "Arch back (cow)", "Round back (cat)", "Move slowly and gently"], icon: "figure.yoga", focusArea: "Spine"),
                Exercise(name: "Child's Pose", duration: 60, instructions: ["Sit back on heels", "Extend arms forward", "Rest forehead on floor", "Breathe deeply"], icon: "figure.mind.and.body", focusArea: "Full Spine")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I am taking the first step toward healing my back."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Breathe in calm, breathe out tension. Follow the rhythm."),
                MentalComponent(type: .reflection, duration: 20, guidance: "Notice how your body feels. Where do you sense relief?")
            ],
            completionMessage: "Day 1 complete! You've started your healing journey. 🌱"
        ),

        DayProgram(
            day: 2,
            title: "Building Awareness",
            theme: "Body Connection",
            mentalFocus: "Listening to Your Body",
            exercises: [
                Exercise(name: "Breathing with Awareness", duration: 60, instructions: ["Focus on natural breath", "Notice where you feel tension", "Breathe into tight areas", "Release on exhale"], icon: "lungs.fill", focusArea: "Mind-Body"),
                Exercise(name: "Gentle Pelvic Tilts", duration: 45, instructions: ["Same as yesterday", "Focus on quality over quantity", "Notice the movement", "Control the pace"], icon: "figure.flexibility", focusArea: "Lower Back"),
                Exercise(name: "Single Knee Rocks", duration: 40, instructions: ["Bring knee to chest", "Gently rock side to side", "Massage lower back", "Switch legs"], icon: "figure.flexibility", focusArea: "Lower Back"),
                Exercise(name: "Supine Twist", duration: 35, instructions: ["Knees bent, feet flat", "Drop knees to one side", "Keep shoulders down", "Switch sides slowly"], icon: "figure.yoga", focusArea: "Spine Rotation"),
                Exercise(name: "Rest and Breathe", duration: 60, instructions: ["Lie flat, body relaxed", "Scan from head to toe", "Notice areas of release", "Breathe naturally"], icon: "figure.mind.and.body", focusArea: "Recovery")
            ],
            mentalComponents: [
                MentalComponent(type: .bodyScan, duration: 30, guidance: "Scan your body from head to toe. Notice without judgment."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Box breathing: In for 4, hold for 4, out for 4, hold for 4."),
                MentalComponent(type: .affirmation, duration: 15, guidance: "My body knows how to heal. I am patient with the process.")
            ],
            completionMessage: "Day 2 done! You're building body awareness. 🧘"
        ),

        DayProgram(
            day: 3,
            title: "Gentle Strength",
            theme: "Core Activation",
            mentalFocus: "Building Confidence",
            exercises: [
                Exercise(name: "Diaphragmatic Breathing", duration: 60, instructions: ["Hand on belly, hand on chest", "Breathe so belly rises first", "Chest stays relatively still", "Strengthen core connection"], icon: "wind", focusArea: "Core Connection"),
                Exercise(name: "Dead Bug Prep", duration: 40, instructions: ["Lie on back, knees up", "Hover one foot off floor", "Keep back pressed down", "Alternate legs"], icon: "figure.core.training", focusArea: "Core"),
                Exercise(name: "Bridge Hold", duration: 30, instructions: ["Feet flat, knees bent", "Lift hips gently", "Squeeze glutes lightly", "Lower slowly"], icon: "figure.strengthtraining.traditional", focusArea: "Glutes & Back"),
                Exercise(name: "Bird Dog Prep", duration: 35, instructions: ["Hands and knees position", "Lift one arm forward", "Keep hips level", "Alternate arms"], icon: "figure.mind.and.body", focusArea: "Stability"),
                Exercise(name: "Restful Recovery", duration: 60, instructions: ["Child's pose or back lying", "Deep, slow breaths", "Feel the strength you built", "Rest fully"], icon: "figure.cooldown", focusArea: "Recovery")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I am building strength with every gentle movement."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Breathe deeply. Feel your core engage naturally with each breath."),
                MentalComponent(type: .reflection, duration: 20, guidance: "Notice the difference between Day 1 and today. Progress is happening.")
            ],
            completionMessage: "Day 3 complete! Your core is waking up. 💪"
        ),

        DayProgram(
            day: 4,
            title: "Flow and Release",
            theme: "Movement Medicine",
            mentalFocus: "Embracing Movement",
            exercises: [
                Exercise(name: "Breath Flow", duration: 45, instructions: ["Match movement to breath", "Inhale as you prepare", "Exhale as you move", "Find your rhythm"], icon: "wind.circle.fill", focusArea: "Flow State"),
                Exercise(name: "Cat-Cow Flow", duration: 60, instructions: ["Hands and knees", "Inhale: cow (arch)", "Exhale: cat (round)", "Flow continuously"], icon: "figure.yoga", focusArea: "Spine Mobility"),
                Exercise(name: "Thread the Needle", duration: 40, instructions: ["From hands and knees", "Thread one arm under body", "Rest on shoulder", "Gentle twist for each side"], icon: "figure.flexibility", focusArea: "Upper Back"),
                Exercise(name: "Glute Bridges", duration: 35, instructions: ["Flow up and down", "Match to breath", "Feel glutes engage", "Control the movement"], icon: "figure.strengthtraining.traditional", focusArea: "Glutes"),
                Exercise(name: "Calming Rest", duration: 60, instructions: ["Lie comfortably", "Notice warmth in muscles", "Appreciate your effort", "Breathe gratitude"], icon: "heart.fill", focusArea: "Gratitude")
            ],
            mentalComponents: [
                MentalComponent(type: .breathing, duration: 30, guidance: "4-7-8 breathing: In for 4, hold for 7, out for 8. Deeply calming."),
                MentalComponent(type: .affirmation, duration: 15, guidance: "Movement is medicine. My body is healing with each flow."),
                MentalComponent(type: .bodyScan, duration: 25, guidance: "Where do you feel warmth? That's your body healing itself.")
            ],
            completionMessage: "Day 4 mastered! You're finding your flow. 🌊"
        ),

        DayProgram(
            day: 5,
            title: "Opening Up",
            theme: "Hip Release",
            mentalFocus: "Letting Go",
            exercises: [
                Exercise(name: "Mindful Breathing", duration: 45, instructions: ["Breathe into your hips", "Imagine tension melting", "Each exhale releases more", "Feel the opening"], icon: "wind", focusArea: "Hip Awareness"),
                Exercise(name: "Figure 4 Stretch", duration: 50, instructions: ["Ankle over opposite knee", "Gently pull leg toward chest", "Feel hip opening", "Switch sides"], icon: "figure.flexibility", focusArea: "Hips"),
                Exercise(name: "Knee Rocks", duration: 40, instructions: ["Both knees to chest", "Rock gently side to side", "Massage lower back", "Stay relaxed"], icon: "figure.yoga", focusArea: "Lower Back"),
                Exercise(name: "Happy Baby Pose", duration: 45, instructions: ["Hold outside of feet", "Knees wide", "Gently rock", "Smile and breathe"], icon: "figure.mind.and.body", focusArea: "Hips & Lower Back"),
                Exercise(name: "Integration Rest", duration: 60, instructions: ["Legs extended or bent", "Feel the openness created", "Body is spacious", "Rest in this feeling"], icon: "sparkles", focusArea: "Integration")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I release what no longer serves me. My body is opening."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Exhale tension. Inhale space. Let go with every breath."),
                MentalComponent(type: .reflection, duration: 25, guidance: "What are you ready to let go of? Physical tension? Mental worry?")
            ],
            completionMessage: "Day 5 done! You're creating space for healing. ✨"
        ),

        DayProgram(
            day: 6,
            title: "Core Connection",
            theme: "Stability Building",
            mentalFocus: "Inner Strength",
            exercises: [
                Exercise(name: "Core Breathing", duration: 45, instructions: ["Feel core engage on exhale", "Gentle, not forced", "Connection, not tension", "Build awareness"], icon: "wind.circle", focusArea: "Core"),
                Exercise(name: "Dead Bug", duration: 45, instructions: ["Opposite arm and leg extend", "Keep back pressed down", "Move with control", "Alternate slowly"], icon: "figure.core.training", focusArea: "Core Stability"),
                Exercise(name: "Bird Dog", duration: 45, instructions: ["Opposite arm and leg lift", "Stay balanced", "Keep hips level", "Quality over speed"], icon: "figure.mind.and.body", focusArea: "Back Stability"),
                Exercise(name: "Plank Hold (Knees)", duration: 20, instructions: ["Forearms down, knees down", "Straight line from knees to head", "Breathe steadily", "Hold strong"], icon: "figure.strengthtraining.traditional", focusArea: "Full Core"),
                Exercise(name: "Child's Pose Recovery", duration: 60, instructions: ["Rest completely", "Feel your new strength", "Breathe appreciation", "Honor your effort"], icon: "figure.cooldown", focusArea: "Recovery")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I am stronger than I was yesterday. My core supports me."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Power breath: Strong inhale through nose, powerful exhale through mouth."),
                MentalComponent(type: .bodyScan, duration: 25, guidance: "Feel the strength in your center. This is your foundation.")
            ],
            completionMessage: "Day 6 complete! Your core is getting stronger. 🔥"
        ),

        DayProgram(
            day: 7,
            title: "Week One Victory",
            theme: "Integration & Rest",
            mentalFocus: "Celebrating Progress",
            exercises: [
                Exercise(name: "Gratitude Breathing", duration: 60, instructions: ["Breathe in: 'I am grateful'", "Breathe out: 'I am healing'", "Feel the truth of this", "Celebrate yourself"], icon: "heart.circle.fill", focusArea: "Gratitude"),
                Exercise(name: "Gentle Flow", duration: 60, instructions: ["Cat-cow at your pace", "Pelvic tilts", "Child's pose", "Move intuitively"], icon: "figure.yoga", focusArea: "Full Body"),
                Exercise(name: "Hip Openers", duration: 50, instructions: ["Figure 4 both sides", "Knee rocks", "Happy baby", "Feel the release"], icon: "figure.flexibility", focusArea: "Hips"),
                Exercise(name: "Core Check-In", duration: 40, instructions: ["Brief dead bug", "Quick bird dog", "Short bridge hold", "Notice the difference"], icon: "figure.core.training", focusArea: "Core"),
                Exercise(name: "Savasana (Deep Rest)", duration: 90, instructions: ["Lie completely still", "Scan your whole body", "Notice all the changes", "Rest in your achievement"], icon: "sparkles", focusArea: "Recovery & Integration")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 20, guidance: "I completed Week 1. I am committed to my healing journey."),
                MentalComponent(type: .reflection, duration: 40, guidance: "Reflect on this week. What changed? What surprised you? What are you proud of?"),
                MentalComponent(type: .breathing, duration: 30, guidance: "Celebrating breath: Breathe in joy, breathe out any remaining doubt.")
            ],
            completionMessage: "WEEK 1 COMPLETE! You showed up for yourself every day. 🎉"
        ),

        // WEEK 2: STRENGTHEN (Days 8-14) - Building Core & Stability
        DayProgram(
            day: 8,
            title: "Level Up",
            theme: "Progressive Strength",
            mentalFocus: "Embracing Challenge",
            exercises: [
                Exercise(name: "Power Breathing", duration: 45, instructions: ["Strong, controlled breaths", "Feel your power", "Energy building", "Confidence growing"], icon: "wind.snow", focusArea: "Energy"),
                Exercise(name: "Advanced Dead Bug", duration: 50, instructions: ["Lower arm and leg together", "Controlled movement", "Back stays down", "Full range of motion"], icon: "figure.core.training", focusArea: "Core"),
                Exercise(name: "Bird Dog with Hold", duration: 45, instructions: ["Extend and hold for 5 seconds", "Perfect balance", "Alternate sides", "Stay strong"], icon: "figure.mind.and.body", focusArea: "Stability"),
                Exercise(name: "Bridge March", duration: 45, instructions: ["Hold bridge position", "Lift one foot slightly", "Alternate legs", "Hips stay level"], icon: "figure.strengthtraining.traditional", focusArea: "Glutes & Stability"),
                Exercise(name: "Recovery Flow", duration: 60, instructions: ["Child's pose", "Gentle stretches", "Feel the strength", "Rest proud"], icon: "figure.cooldown", focusArea: "Recovery")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I welcome challenge. I am capable of more than I thought."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Breath of strength: Inhale power, exhale limitation."),
                MentalComponent(type: .reflection, duration: 20, guidance: "Notice what feels easier than last week. That's progress.")
            ],
            completionMessage: "Day 8 crushed! Week 2 has begun strong. 💪"
        ),

        DayProgram(
            day: 9,
            title: "Postural Power",
            theme: "Alignment Focus",
            mentalFocus: "Standing Tall",
            exercises: [
                Exercise(name: "Posture Awareness Breathing", duration: 45, instructions: ["Sit or stand tall", "Breathe into good posture", "Shoulders back and down", "Feel your spine lengthen"], icon: "figure.stand", focusArea: "Posture"),
                Exercise(name: "Wall Angels", duration: 50, instructions: ["Back against wall", "Arms slide up and down", "Maintain contact with wall", "Open chest and shoulders"], icon: "figure.flexibility", focusArea: "Upper Back"),
                Exercise(name: "Prone Cobra", duration: 30, instructions: ["Lie face down", "Lift chest slightly", "Squeeze shoulder blades", "Strengthen upper back"], icon: "figure.strengthtraining.traditional", focusArea: "Upper Back"),
                Exercise(name: "Quadruped Thoracic Rotation", duration: 45, instructions: ["Hands and knees", "Hand behind head", "Rotate torso open", "Improve spine rotation"], icon: "figure.yoga", focusArea: "Thoracic Spine"),
                Exercise(name: "Postural Reset", duration: 60, instructions: ["Stand tall or sit tall", "Scan your alignment", "Breathe into length", "Embody good posture"], icon: "figure.stand.line.dotted.figure.stand", focusArea: "Integration")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I carry myself with strength and grace. My posture reflects my confidence."),
                MentalComponent(type: .bodyScan, duration: 30, guidance: "Scan from feet to crown. Where can you create more space?"),
                MentalComponent(type: .breathing, duration: 25, guidance: "Tall breath: Inhale and grow taller, exhale and maintain height.")
            ],
            completionMessage: "Day 9 done! Standing taller already. 🌟"
        ),

        DayProgram(
            day: 10,
            title: "Dynamic Stability",
            theme: "Controlled Movement",
            mentalFocus: "Grace Under Pressure",
            exercises: [
                Exercise(name: "Mindful Movement Prep", duration: 40, instructions: ["Center yourself", "Feel grounded", "Prepare to move with control", "Breathe confidence"], icon: "figure.mind.and.body", focusArea: "Centering"),
                Exercise(name: "Single Leg Bridge", duration: 50, instructions: ["Bridge with one leg extended", "Hold stable", "Glutes engaged", "Alternate legs"], icon: "figure.strengthtraining.traditional", focusArea: "Glutes & Balance"),
                Exercise(name: "Plank to Down Dog", duration: 45, instructions: ["From plank (knees optional)", "Push back to down dog", "Return to plank", "Controlled flow"], icon: "figure.yoga", focusArea: "Full Body"),
                Exercise(name: "Side Plank (Knees)", duration: 30, instructions: ["Side plank from knees", "Hold stable", "Breathe steadily", "Both sides"], icon: "figure.core.training", focusArea: "Obliques"),
                Exercise(name: "Constructive Rest", duration: 60, instructions: ["Knees bent, feet flat", "Arms at sides", "Full body relaxation", "Integrate the work"], icon: "figure.cooldown", focusArea: "Recovery")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I am balanced and stable. I move through life with grace."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Balance breath: Equal inhale and exhale. Find equilibrium."),
                MentalComponent(type: .reflection, duration: 20, guidance: "How does your improved stability feel in daily life?")
            ],
            completionMessage: "Day 10 complete! Finding your balance. ⚖️"
        ),

        DayProgram(
            day: 11,
            title: "Endurance Builder",
            theme: "Sustained Strength",
            mentalFocus: "Mental Toughness",
            exercises: [
                Exercise(name: "Endurance Breathing", duration: 45, instructions: ["Steady, rhythmic breath", "Build mental stamina", "Consistent pace", "Prepare for challenge"], icon: "wind", focusArea: "Mental Prep"),
                Exercise(name: "Extended Plank Hold", duration: 40, instructions: ["Knees or toes", "Hold with good form", "Breathe through it", "Mental strength building"], icon: "figure.strengthtraining.traditional", focusArea: "Core Endurance"),
                Exercise(name: "Wall Sit", duration: 45, instructions: ["Back against wall", "Knees at 90 degrees", "Hold position", "Legs building strength"], icon: "figure.flexibility", focusArea: "Leg Strength"),
                Exercise(name: "Superman Hold", duration: 30, instructions: ["Lie face down", "Lift arms and legs", "Hold the position", "Back extension strength"], icon: "figure.core.training", focusArea: "Back Strength"),
                Exercise(name: "Deep Recovery", duration: 90, instructions: ["You earned this rest", "Muscles recovering", "Strength is building", "Honor your effort"], icon: "heart.fill", focusArea: "Recovery")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I am mentally tough. I push through when it gets hard."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Warrior breath: Strong inhales, powerful exhales. You are a warrior."),
                MentalComponent(type: .bodyScan, duration: 25, guidance: "Feel the burn becoming strength. That's transformation.")
            ],
            completionMessage: "Day 11 conquered! Your endurance is growing. 🔥"
        ),

        DayProgram(
            day: 12,
            title: "Functional Movement",
            theme: "Real-World Strength",
            mentalFocus: "Practical Power",
            exercises: [
                Exercise(name: "Functional Breathing", duration: 40, instructions: ["Breathe as you move", "Natural rhythm", "Real-world connection", "Movement is life"], icon: "wind.circle", focusArea: "Integration"),
                Exercise(name: "Squat to Stand", duration: 50, instructions: ["From chair or bench", "Stand up fully", "Sit down controlled", "Daily life movement"], icon: "figure.strengthtraining.functional", focusArea: "Legs & Back"),
                Exercise(name: "Bent-Over Row (No Weight)", duration: 45, instructions: ["Hinge at hips", "Pull elbows back", "Squeeze shoulder blades", "Upper back strength"], icon: "figure.strengthtraining.traditional", focusArea: "Upper Back"),
                Exercise(name: "Rotational Reaches", duration: 45, instructions: ["Controlled trunk rotation", "Reach across body", "Functional spine movement", "Both directions"], icon: "figure.core.training", focusArea: "Rotational Strength"),
                Exercise(name: "Standing Recovery", duration: 60, instructions: ["Stand tall", "Gentle movements", "Feel how strong you are", "This is real strength"], icon: "figure.stand", focusArea: "Empowerment")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I am strong in my daily life. Every movement is easier now."),
                MentalComponent(type: .reflection, duration: 30, guidance: "What daily tasks feel easier? Picking things up? Getting up from a chair?"),
                MentalComponent(type: .breathing, duration: 25, guidance: "Practical breath: Notice how breath supports real movement.")
            ],
            completionMessage: "Day 12 mastered! Real-world strength gained. 💼"
        ),

        DayProgram(
            day: 13,
            title: "Power Day",
            theme: "Peak Performance",
            mentalFocus: "Unleashing Potential",
            exercises: [
                Exercise(name: "Power Prep Breathing", duration: 45, instructions: ["Quick, energizing breaths", "Build internal fire", "Feel your power", "Ready to dominate"], icon: "bolt.fill", focusArea: "Energy"),
                Exercise(name: "Dynamic Bird Dog", duration: 50, instructions: ["Full extension", "Hold briefly", "Quick transitions", "Maximum engagement"], icon: "figure.core.training", focusArea: "Core Power"),
                Exercise(name: "Explosive Bridges", duration: 45, instructions: ["Push up with power", "Controlled lower", "Glutes firing", "Building explosive strength"], icon: "figure.strengthtraining.traditional", focusArea: "Glutes"),
                Exercise(name: "Mountain Climbers (Modified)", duration: 40, instructions: ["Plank position", "Knee to chest alternating", "Controlled pace", "Core and cardio"], icon: "figure.run", focusArea: "Full Body"),
                Exercise(name: "Power Down Rest", duration: 90, instructions: ["You crushed it", "Deep, restorative breathing", "Muscles repairing", "Champions rest well"], icon: "crown.fill", focusArea: "Champion Recovery")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I am powerful. My body is capable of amazing things."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Victory breath: Breathe in success, exhale any self-doubt."),
                MentalComponent(type: .reflection, duration: 25, guidance: "You just did exercises that seemed impossible two weeks ago. Feel that.")
            ],
            completionMessage: "Day 13 demolished! You are POWERFUL. ⚡"
        ),

        DayProgram(
            day: 14,
            title: "Week Two Champion",
            theme: "Strength Integration",
            mentalFocus: "Owning Your Progress",
            exercises: [
                Exercise(name: "Champion's Breathing", duration: 60, instructions: ["Breathe like a champion", "You've earned this title", "Two weeks of consistency", "Feel the pride"], icon: "crown.fill", focusArea: "Confidence"),
                Exercise(name: "Full Body Flow", duration: 70, instructions: ["Cat-cow flow", "Bird dog both sides", "Bridges with control", "Your strongest versions"], icon: "figure.yoga", focusArea: "Integration"),
                Exercise(name: "Core Challenge", duration: 60, instructions: ["Plank hold", "Dead bug", "Side planks", "Show your strength"], icon: "figure.core.training", focusArea: "Core Mastery"),
                Exercise(name: "Posture Power", duration: 50, instructions: ["Wall angels", "Prone cobras", "Stand tall and proud", "Embody strength"], icon: "figure.stand", focusArea: "Posture"),
                Exercise(name: "Victory Savasana", duration: 120, instructions: ["Lie in complete rest", "Reflect on 14 days", "Two full weeks completed", "You are transformed"], icon: "sparkles", focusArea: "Celebration")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 20, guidance: "I completed Week 2. I am stronger, more stable, and more confident."),
                MentalComponent(type: .reflection, duration: 60, guidance: "Compare Day 1 to Day 14. What changed physically? Mentally? Emotionally?"),
                MentalComponent(type: .breathing, duration: 30, guidance: "Gratitude breath: Thank your body for its incredible healing capacity.")
            ],
            completionMessage: "WEEK 2 COMPLETE! You are officially strong. Halfway to your goal! 🏆"
        ),

        // WEEK 3: MOBILIZE (Days 15-21) - Flexibility & Stress Release
        DayProgram(
            day: 15,
            title: "Opening New Doors",
            theme: "Flexibility Focus",
            mentalFocus: "Expanding Possibilities",
            exercises: [
                Exercise(name: "Expansive Breathing", duration: 60, instructions: ["Breathe into all areas", "Feel your body expand", "Creating space", "Opening to possibilities"], icon: "wind", focusArea: "Expansion"),
                Exercise(name: "Deep Hip Flexor Stretch", duration: 60, instructions: ["Low lunge position", "Feel deep hip opening", "Hold and breathe", "Both sides"], icon: "figure.flexibility", focusArea: "Hip Flexors"),
                Exercise(name: "Seated Forward Fold", duration: 50, instructions: ["Sit with legs extended", "Reach toward toes", "Bend from hips", "Hamstring opening"], icon: "figure.yoga", focusArea: "Hamstrings"),
                Exercise(name: "Reclined Hamstring Stretch", duration: 50, instructions: ["Strap or towel around foot", "Gently pull leg toward you", "Keep knee soft", "Both sides"], icon: "figure.flexibility", focusArea: "Hamstrings"),
                Exercise(name: "Openness Integration", duration: 70, instructions: ["Notice the new space", "Breathe into it", "Feel the expansion", "Rest in openness"], icon: "sparkles", focusArea: "Integration")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I am flexible in body and mind. I open to new possibilities."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Expansion breath: Each inhale creates more internal space."),
                MentalComponent(type: .reflection, duration: 25, guidance: "Where else in life can you be more flexible?")
            ],
            completionMessage: "Day 15 done! Week 3: Flexibility has begun. 🌈"
        ),

        DayProgram(
            day: 16,
            title: "Tension Release",
            theme: "Letting Go Deeply",
            mentalFocus: "Emotional Release",
            exercises: [
                Exercise(name: "Release Breathing", duration: 60, instructions: ["Sigh out loud on exhale", "Let go audibly", "Release stored tension", "Sound is healing"], icon: "wind.snow", focusArea: "Emotional Release"),
                Exercise(name: "Supine Twist Deep Hold", duration: 60, instructions: ["Hold twist for full time", "Breathe into it", "Allow deep release", "Each side"], icon: "figure.yoga", focusArea: "Spine Release"),
                Exercise(name: "Pigeon Pose", duration: 70, instructions: ["Deep hip opener", "Forward fold over front leg", "Breathe through emotion", "Hold and release"], icon: "figure.flexibility", focusArea: "Deep Hip Release"),
                Exercise(name: "Legs Up the Wall", duration: 90, instructions: ["Hips close to wall", "Legs straight up", "Arms wide", "Full body release"], icon: "figure.cooldown", focusArea: "Full Release"),
                Exercise(name: "Emotional Integration", duration: 80, instructions: ["Notice what came up", "Allow all feelings", "No judgment", "You are safe"], icon: "heart.fill", focusArea: "Emotional Healing")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I release what I've been holding. It is safe to let go."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Letting go breath: Exhale is longer than inhale. Release with sound."),
                MentalComponent(type: .reflection, duration: 30, guidance: "What emotional tension have you been carrying in your back?")
            ],
            completionMessage: "Day 16 complete! You released more than just physical tension. 🕊️"
        ),

        DayProgram(
            day: 17,
            title: "Flow State",
            theme: "Fluid Movement",
            mentalFocus: "Being Present",
            exercises: [
                Exercise(name: "Flow Breathing", duration: 60, instructions: ["Breath and movement unite", "No separation", "Pure flow state", "Present moment awareness"], icon: "water.waves", focusArea: "Presence"),
                Exercise(name: "Sun Salutation (Modified)", duration: 90, instructions: ["Flow through positions", "Match breath to movement", "Continuous motion", "Find your rhythm"], icon: "figure.yoga", focusArea: "Full Body Flow"),
                Exercise(name: "Dynamic Cat-Cow", duration: 60, instructions: ["Flow continuously", "Never stop moving", "Breath leads movement", "Pure flow"], icon: "figure.flexibility", focusArea: "Spine Flow"),
                Exercise(name: "Standing Flow Sequence", duration: 70, instructions: ["Gentle standing stretches", "Flow from one to next", "Stay in movement", "Grace and ease"], icon: "figure.mind.and.body", focusArea: "Standing Flow"),
                Exercise(name: "Still Point", duration: 90, instructions: ["After flow comes stillness", "Feel energy moving", "Present in your body", "Flow within stillness"], icon: "sparkles", focusArea: "Presence")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I flow through life with ease and grace. I am present."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Ocean breath: Like waves, continuous and rhythmic."),
                MentalComponent(type: .reflection, duration: 25, guidance: "When did you lose track of time today? That was flow.")
            ],
            completionMessage: "Day 17 mastered! You found your flow. 🌊"
        ),

        DayProgram(
            day: 18,
            title: "Thoracic Freedom",
            theme: "Upper Back Mobility",
            mentalFocus: "Opening the Heart",
            exercises: [
                Exercise(name: "Heart Opening Breathing", duration: 60, instructions: ["Breathe into your chest", "Feel heart space expand", "Shoulders back naturally", "Emotional opening"], icon: "heart.circle", focusArea: "Heart Space"),
                Exercise(name: "Thoracic Extensions", duration: 50, instructions: ["Over foam roller or pillow", "Gentle backbend", "Arms overhead", "Upper back opening"], icon: "figure.flexibility", focusArea: "Thoracic Spine"),
                Exercise(name: "Thread the Needle Flow", duration: 60, instructions: ["Flow between both sides", "Deep shoulder stretch", "Thoracic rotation", "Continuous movement"], icon: "figure.yoga", focusArea: "Shoulders & T-Spine"),
                Exercise(name: "Doorway Chest Stretch", duration: 50, instructions: ["Arm on doorframe", "Gentle lean forward", "Chest opening", "Both sides"], icon: "figure.flexibility", focusArea: "Chest & Shoulders"),
                Exercise(name: "Heart Space Rest", duration: 80, instructions: ["Lie with support under shoulder blades", "Arms wide", "Chest open", "Breathe into heart"], icon: "heart.fill", focusArea: "Heart Opening")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "My heart is open. I receive and give love freely."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Heart breath: Breathe in love, breathe out fear."),
                MentalComponent(type: .bodyScan, duration: 25, guidance: "What do you feel in your heart space? Honor it.")
            ],
            completionMessage: "Day 18 done! Your heart space is open. 💚"
        ),

        DayProgram(
            day: 19,
            title: "Lower Body Liberation",
            theme: "Hip & Leg Mobility",
            mentalFocus: "Grounding & Release",
            exercises: [
                Exercise(name: "Grounding Breathing", duration: 60, instructions: ["Breathe down into legs", "Feel connection to earth", "Roots growing deep", "Stable and grounded"], icon: "leaf.fill", focusArea: "Grounding"),
                Exercise(name: "Deep Lunge Series", duration: 70, instructions: ["Low lunge variations", "Hold each deeply", "Hip flexor opening", "Feel the release"], icon: "figure.flexibility", focusArea: "Hip Flexors"),
                Exercise(name: "90/90 Hip Stretch", duration: 60, instructions: ["Both knees at 90 degrees", "Sit between feet", "Deep hip rotation work", "Breathe into tightness"], icon: "figure.yoga", focusArea: "Hip Rotators"),
                Exercise(name: "Calf and Hamstring Flow", duration: 60, instructions: ["Downward dog variations", "Pedal feet", "Bend and straighten knees", "Full leg opening"], icon: "figure.flexibility", focusArea: "Legs"),
                Exercise(name: "Grounded Rest", duration: 80, instructions: ["Feel heavy and grounded", "Supported by earth", "Lower body released", "Deep rest"], icon: "figure.cooldown", focusArea: "Grounding")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I am grounded and stable. My foundation is strong."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Earth breath: Exhale down into the ground, release into earth."),
                MentalComponent(type: .reflection, duration: 25, guidance: "What helps you feel grounded in daily life?")
            ],
            completionMessage: "Day 19 complete! Grounded and free. 🌍"
        ),

        DayProgram(
            day: 20,
            title: "Full Body Freedom",
            theme: "Complete Mobility",
            mentalFocus: "Wholeness",
            exercises: [
                Exercise(name: "Whole Body Breathing", duration: 60, instructions: ["Breathe into every cell", "Full body awareness", "Complete integration", "You are whole"], icon: "wind.circle.fill", focusArea: "Wholeness"),
                Exercise(name: "Full Sun Salutation", duration: 90, instructions: ["Complete flow sequence", "Every part moves", "Breath guides all", "Integrated movement"], icon: "figure.yoga", focusArea: "Full Body"),
                Exercise(name: "Comprehensive Stretch Sequence", duration: 90, instructions: ["Neck to toes", "Every major muscle group", "Hold each briefly", "Complete body opening"], icon: "figure.flexibility", focusArea: "Full Body Mobility"),
                Exercise(name: "Spinal Waves", duration: 60, instructions: ["Articulate entire spine", "Sequential movement", "Head to tailbone", "Fluid spine"], icon: "figure.mind.and.body", focusArea: "Full Spine"),
                Exercise(name: "Whole Body Integration", duration: 100, instructions: ["Lie in complete rest", "Scan every part", "Notice the freedom", "You are transformed"], icon: "sparkles", focusArea: "Integration")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 20, guidance: "I am whole, complete, and free. My body moves with ease."),
                MentalComponent(type: .bodyScan, duration: 40, guidance: "Scan from head to toe. Notice the difference from Day 1."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Unity breath: All parts breathing as one whole.")
            ],
            completionMessage: "Day 20 mastered! You are free in your body. ✨"
        ),

        DayProgram(
            day: 21,
            title: "Week Three Victory",
            theme: "Flexibility Celebration",
            mentalFocus: "Embracing Change",
            exercises: [
                Exercise(name: "Transformation Breathing", duration: 70, instructions: ["Reflect on three weeks", "Feel how much has changed", "Breathe gratitude", "Celebrate transformation"], icon: "sparkles", focusArea: "Transformation"),
                Exercise(name: "Freedom Flow", duration: 100, instructions: ["Move completely freely", "Your favorite stretches", "Intuitive movement", "Express your freedom"], icon: "figure.dance", focusArea: "Free Movement"),
                Exercise(name: "Deep Hip Opening", duration: 80, instructions: ["Pigeon, figure 4, happy baby", "Hold each long", "Release completely", "You are open"], icon: "figure.flexibility", focusArea: "Hips"),
                Exercise(name: "Full Spine Mobility", duration: 70, instructions: ["All spine movements", "Flexion, extension, rotation", "Complete range", "Spine is free"], icon: "figure.yoga", focusArea: "Spine"),
                Exercise(name: "Victory Savasana", duration: 120, instructions: ["Three weeks complete", "You are remarkable", "Rest in this achievement", "One more week to go"], icon: "crown.fill", focusArea: "Celebration")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 20, guidance: "I embrace change. I am flexible in body, mind, and spirit."),
                MentalComponent(type: .reflection, duration: 60, guidance: "What has shifted in your life beyond back pain? What else changed?"),
                MentalComponent(type: .breathing, duration: 30, guidance: "Change breath: Each breath is a new beginning.")
            ],
            completionMessage: "WEEK 3 COMPLETE! You are mobile, flexible, and free. Final week awaits! 🎊"
        ),

        // WEEK 4: SUSTAIN (Days 22-28) - Integration & Long-term Wellness
        DayProgram(
            day: 22,
            title: "Building Habits",
            theme: "Sustainable Practice",
            mentalFocus: "Long-term Commitment",
            exercises: [
                Exercise(name: "Commitment Breathing", duration: 60, instructions: ["Breathe into your future", "See yourself continuing", "This is who you are now", "Committed to wellness"], icon: "heart.fill", focusArea: "Commitment"),
                Exercise(name: "Essential Core Work", duration: 60, instructions: ["Dead bug, bird dog, planks", "Your foundation exercises", "These are your staples", "Master the basics"], icon: "figure.core.training", focusArea: "Core Maintenance"),
                Exercise(name: "Daily Hip Openers", duration: 60, instructions: ["Figure 4, pigeon, lunges", "Hip health for life", "Daily maintenance", "Keep hips happy"], icon: "figure.flexibility", focusArea: "Hip Maintenance"),
                Exercise(name: "Posture Check-In", duration: 50, instructions: ["Wall angels, cobras", "Daily posture work", "Stand tall always", "Posture is power"], icon: "figure.stand", focusArea: "Posture"),
                Exercise(name: "Sustainable Rest", duration: 70, instructions: ["Brief but deep", "Quality over quantity", "Efficient recovery", "This is sustainable"], icon: "figure.cooldown", focusArea: "Recovery")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "This is my new normal. I am committed to my daily practice."),
                MentalComponent(type: .reflection, duration: 30, guidance: "How will you make this a permanent part of your life?"),
                MentalComponent(type: .breathing, duration: 25, guidance: "Sustainable breath: Steady, consistent, forever.")
            ],
            completionMessage: "Day 22 done! Building habits that last. 🌱"
        ),

        DayProgram(
            day: 23,
            title: "Minimum Effective Dose",
            theme: "Efficiency",
            mentalFocus: "Quality Over Quantity",
            exercises: [
                Exercise(name: "Focused Breathing", duration: 50, instructions: ["Less time, more focus", "Each breath counts", "Quality attention", "Efficient practice"], icon: "target", focusArea: "Focus"),
                Exercise(name: "Power Core Circuit", duration: 70, instructions: ["Best core exercises only", "Perfect form", "Maximum benefit", "Minimal time"], icon: "figure.core.training", focusArea: "Efficient Core"),
                Exercise(name: "Essential Stretches", duration: 60, instructions: ["Only the most impactful", "Biggest bang for buck", "Hips, hamstrings, spine", "Smart stretching"], icon: "figure.flexibility", focusArea: "Essential Mobility"),
                Exercise(name: "Quick Posture Reset", duration: 40, instructions: ["Fastest posture fixes", "Most effective cues", "Stand tall quickly", "Efficient alignment"], icon: "figure.stand", focusArea: "Quick Posture"),
                Exercise(name: "Effective Rest", duration: 60, instructions: ["Even rest is efficient", "Deep relaxation quickly", "Recover fast", "Move on with your day"], icon: "bolt.fill", focusArea: "Efficient Recovery")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "Less can be more. I focus on what matters most."),
                MentalComponent(type: .reflection, duration: 25, guidance: "Which exercises give you the most benefit? Focus there."),
                MentalComponent(type: .breathing, duration: 20, guidance: "Efficient breath: Deep and focused, not long and scattered.")
            ],
            completionMessage: "Day 23 complete! Work smarter, not harder. 🎯"
        ),

        DayProgram(
            day: 24,
            title: "Real Life Integration",
            theme: "Living Your Practice",
            mentalFocus: "Movement as Lifestyle",
            exercises: [
                Exercise(name: "Life Breathing", duration: 50, instructions: ["Breathe like this all day", "Not just during practice", "Every breath matters", "Life is practice"], icon: "wind", focusArea: "Lifestyle Integration"),
                Exercise(name: "Chair Exercises", duration: 60, instructions: ["Work-friendly movements", "At your desk", "In daily life", "Always accessible"], icon: "figure.stand", focusArea: "Office Wellness"),
                Exercise(name: "Micro-Movements", duration: 50, instructions: ["Tiny movements, big impact", "While standing in line", "Waiting for coffee", "Life is movement"], icon: "figure.walk", focusArea: "Daily Movement"),
                Exercise(name: "Posture Anywhere", duration: 50, instructions: ["Practice good posture now", "In car, at desk, standing", "Constant awareness", "Posture is practice"], icon: "figure.stand.line.dotted.figure.stand", focusArea: "Lifestyle Posture"),
                Exercise(name: "Life Integration Rest", duration: 70, instructions: ["Rest is also life skill", "Breathe anywhere", "Quick resets all day", "Wellness is lifestyle"], icon: "heart.circle.fill", focusArea: "Lifestyle Wellness")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "My practice extends into every moment. I live well."),
                MentalComponent(type: .reflection, duration: 30, guidance: "How can you integrate these principles into your whole day?"),
                MentalComponent(type: .breathing, duration: 25, guidance: "Anywhere breath: You can practice breathing anywhere, anytime.")
            ],
            completionMessage: "Day 24 mastered! Living your wellness. 🌟"
        ),

        DayProgram(
            day: 25,
            title: "Prevention Protocol",
            theme: "Staying Pain-Free",
            mentalFocus: "Proactive Wellness",
            exercises: [
                Exercise(name: "Prevention Breathing", duration: 50, instructions: ["Breathe to prevent pain", "Before tension builds", "Proactive, not reactive", "Prevention is power"], icon: "shield.fill", focusArea: "Prevention"),
                Exercise(name: "Daily Spine Care", duration: 70, instructions: ["Cat-cow every day", "Spine mobility daily", "Prevent stiffness", "Daily maintenance"], icon: "figure.yoga", focusArea: "Spine Prevention"),
                Exercise(name: "Hip Health Routine", duration: 60, instructions: ["Keep hips open always", "Prevent tightness", "Daily hip work", "Hips stay healthy"], icon: "figure.flexibility", focusArea: "Hip Prevention"),
                Exercise(name: "Core Maintenance", duration: 60, instructions: ["Strong core prevents pain", "Daily core work", "Maintain your gains", "Protection through strength"], icon: "figure.core.training", focusArea: "Core Prevention"),
                Exercise(name: "Prevention Rest", duration: 70, instructions: ["Rest prevents burnout", "Recovery is prevention", "Rest to stay well", "Sustainable wellness"], icon: "figure.cooldown", focusArea: "Preventive Rest")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I prevent pain before it starts. I am proactive about my health."),
                MentalComponent(type: .reflection, duration: 30, guidance: "What early warning signs will you watch for? How will you respond?"),
                MentalComponent(type: .breathing, duration: 25, guidance: "Prevention breath: Breathe awareness into your body regularly.")
            ],
            completionMessage: "Day 25 done! Prevention is the best medicine. 🛡️"
        ),

        DayProgram(
            day: 26,
            title: "Teaching Moment",
            theme: "Sharing Your Knowledge",
            mentalFocus: "Helping Others",
            exercises: [
                Exercise(name: "Teaching Breathing", duration: 50, instructions: ["Could you teach this?", "Understand it deeply", "Help others breathe", "Share the gift"], icon: "person.2.fill", focusArea: "Teaching"),
                Exercise(name: "Explainable Exercises", duration: 70, instructions: ["Do each as if teaching", "Understand why it works", "Could you explain it?", "Deep knowledge"], icon: "book.fill", focusArea: "Understanding"),
                Exercise(name: "Simple Cues Practice", duration: 60, instructions: ["What would you tell someone?", "Simple, clear cues", "Share the wisdom", "You are knowledgeable"], icon: "text.bubble.fill", focusArea: "Communication"),
                Exercise(name: "Demonstration Quality", duration: 50, instructions: ["Show-ready form", "Perfect enough to teach", "Lead by example", "You are the example"], icon: "star.fill", focusArea: "Mastery"),
                Exercise(name: "Grateful Rest", duration: 80, instructions: ["Grateful you can share", "You have a gift to give", "Rest in that knowledge", "You help others"], icon: "heart.fill", focusArea: "Gratitude")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 15, guidance: "I have knowledge to share. I can help others heal."),
                MentalComponent(type: .reflection, duration: 35, guidance: "Who in your life could benefit from what you've learned?"),
                MentalComponent(type: .breathing, duration: 25, guidance: "Shared breath: Imagine breathing with someone you could help.")
            ],
            completionMessage: "Day 26 complete! You have wisdom to share. 🎓"
        ),

        DayProgram(
            day: 27,
            title: "Confidence Day",
            theme: "Owning Your Transformation",
            mentalFocus: "Self-Assurance",
            exercises: [
                Exercise(name: "Confident Breathing", duration: 60, instructions: ["Breathe with confidence", "You've earned this", "Strong, sure breaths", "Confidence in every inhale"], icon: "sparkles", focusArea: "Confidence"),
                Exercise(name: "Power Demonstration", duration: 80, instructions: ["Show your strongest work", "Advanced variations", "You are capable", "Demonstrate mastery"], icon: "bolt.fill", focusArea: "Power Display"),
                Exercise(name: "Full Range Mobility", duration: 70, instructions: ["Move through complete ranges", "Show your flexibility", "Freedom of movement", "You are mobile"], icon: "figure.flexibility", focusArea: "Mobility Display"),
                Exercise(name: "Controlled Excellence", duration: 70, instructions: ["Perfect form, full control", "Mastery in motion", "Precision and power", "You are skilled"], icon: "target", focusArea: "Mastery"),
                Exercise(name: "Confident Rest", duration: 90, instructions: ["Rest like a champion", "You've proven yourself", "Confident in your body", "You are transformed"], icon: "crown.fill", focusArea: "Champion Rest")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 20, guidance: "I am confident in my body. I trust my strength and capabilities."),
                MentalComponent(type: .reflection, duration: 40, guidance: "List everything you can do now that you couldn't do 27 days ago."),
                MentalComponent(type: .breathing, duration: 30, guidance: "Power breath: Breathe in confidence, breathe out any remaining doubt.")
            ],
            completionMessage: "Day 27 conquered! One day left. You are ready. 💎"
        ),

        DayProgram(
            day: 28,
            title: "The Final Day - Your New Beginning",
            theme: "Completion & Continuation",
            mentalFocus: "Transformation Complete",
            exercises: [
                Exercise(name: "Journey Breathing", duration: 90, instructions: ["Breathe in your whole journey", "Day 1 to now", "Feel every moment", "This is who you are now"], icon: "heart.circle.fill", focusArea: "Reflection"),
                Exercise(name: "Victory Flow", duration: 120, instructions: ["Your favorite movements", "Everything you've learned", "Freedom in motion", "This is your flow"], icon: "figure.dance", focusArea: "Celebration"),
                Exercise(name: "Strength Showcase", duration: 90, instructions: ["Your strongest core work", "Show what you've built", "Power and control", "You are strong"], icon: "figure.strengthtraining.traditional", focusArea: "Strength"),
                Exercise(name: "Flexibility Freedom", duration: 90, instructions: ["Deepest stretches", "Complete range of motion", "You are free", "Movement without pain"], icon: "figure.flexibility", focusArea: "Freedom"),
                Exercise(name: "Final Savasana - New Beginning", duration: 180, instructions: ["This is not the end", "This is your new normal", "You are transformed", "The journey continues"], icon: "infinity", focusArea: "New Beginning")
            ],
            mentalComponents: [
                MentalComponent(type: .affirmation, duration: 30, guidance: "I completed the 28-Day Challenge. I am transformed. I continue forward."),
                MentalComponent(type: .reflection, duration: 120, guidance: "Journal prompt: Write about your transformation. Physical, mental, emotional. What changed? Who are you now?"),
                MentalComponent(type: .breathing, duration: 60, guidance: "Infinite breath: This practice continues forever. You are forever changed.")
            ],
            completionMessage: "🎉 28 DAY CHALLENGE COMPLETE! 🎉\n\nYou did it. Every single day. You showed up for yourself.\n\nYou are no longer the person who started this challenge.\n\nYour back is stronger. Your mind is clearer. Your life is different.\n\nThis isn't the end. This is who you are now.\n\nWelcome to the rest of your life. 🌟"
        )
    ]

    static func getDay(_ dayNumber: Int) -> DayProgram? {
        return allDays.first { $0.day == dayNumber }
    }
}
