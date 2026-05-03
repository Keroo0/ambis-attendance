class DummySubjectGrade {
  final String subject;
  final double utsScore;
  final double uasScore;
  final double tugasScore;

  const DummySubjectGrade({
    required this.subject,
    required this.utsScore,
    required this.uasScore,
    required this.tugasScore,
  });

  double get average => (utsScore + uasScore + tugasScore) / 3;
}

class DummySummary {
  final double overallAverage;
  final int rank;
  final int totalStudents;
  final String predikat;

  const DummySummary({
    required this.overallAverage,
    required this.rank,
    required this.totalStudents,
    required this.predikat,
  });
}

const kDummyGradesSem1 = [
  DummySubjectGrade(subject: 'Matematika',            utsScore: 78, uasScore: 82, tugasScore: 85),
  DummySubjectGrade(subject: 'Bahasa Indonesia',      utsScore: 88, uasScore: 90, tugasScore: 92),
  DummySubjectGrade(subject: 'Bahasa Inggris',        utsScore: 82, uasScore: 85, tugasScore: 88),
  DummySubjectGrade(subject: 'Fisika',                utsScore: 75, uasScore: 79, tugasScore: 83),
  DummySubjectGrade(subject: 'Kimia',                 utsScore: 72, uasScore: 76, tugasScore: 80),
  DummySubjectGrade(subject: 'Biologi',               utsScore: 80, uasScore: 83, tugasScore: 87),
  DummySubjectGrade(subject: 'Sejarah Indonesia',     utsScore: 85, uasScore: 88, tugasScore: 90),
  DummySubjectGrade(subject: 'Pendidikan Pancasila',  utsScore: 90, uasScore: 92, tugasScore: 94),
  DummySubjectGrade(subject: 'Pendidikan Agama Islam',utsScore: 91, uasScore: 93, tugasScore: 95),
  DummySubjectGrade(subject: 'Pendidikan Jasmani',    utsScore: 88, uasScore: 90, tugasScore: 92),
];

const kDummyGradesSem2 = [
  DummySubjectGrade(subject: 'Matematika',            utsScore: 80, uasScore: 84, tugasScore: 87),
  DummySubjectGrade(subject: 'Bahasa Indonesia',      utsScore: 89, uasScore: 91, tugasScore: 93),
  DummySubjectGrade(subject: 'Bahasa Inggris',        utsScore: 84, uasScore: 87, tugasScore: 90),
  DummySubjectGrade(subject: 'Fisika',                utsScore: 77, uasScore: 81, tugasScore: 85),
  DummySubjectGrade(subject: 'Kimia',                 utsScore: 74, uasScore: 78, tugasScore: 82),
  DummySubjectGrade(subject: 'Biologi',               utsScore: 82, uasScore: 85, tugasScore: 89),
  DummySubjectGrade(subject: 'Sejarah Indonesia',     utsScore: 87, uasScore: 89, tugasScore: 92),
  DummySubjectGrade(subject: 'Pendidikan Pancasila',  utsScore: 91, uasScore: 93, tugasScore: 95),
  DummySubjectGrade(subject: 'Pendidikan Agama Islam',utsScore: 92, uasScore: 94, tugasScore: 96),
  DummySubjectGrade(subject: 'Pendidikan Jasmani',    utsScore: 89, uasScore: 91, tugasScore: 93),
];

const kDummySummarySem1 = DummySummary(
  overallAverage: 83.6,
  rank: 5,
  totalStudents: 32,
  predikat: 'B+',
);

const kDummySummarySem2 = DummySummary(
  overallAverage: 85.3,
  rank: 4,
  totalStudents: 32,
  predikat: 'A-',
);
