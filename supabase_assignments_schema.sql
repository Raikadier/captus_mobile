-- ==============================================================================
-- 1. TABLAS PRINCIPALES
-- ==============================================================================

-- (Opcional: Si no tienes la tabla profiles, asume esta estructura)
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  name TEXT,
  email TEXT,
  role TEXT CHECK (role IN ('student', 'teacher')),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla de Tareas (Assignments)
CREATE TABLE public.assignments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  course_id UUID, -- Aquí puedes agregar: REFERENCES public.courses(id)
  teacher_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  start_date TIMESTAMPTZ,
  due_date TIMESTAMPTZ NOT NULL,
  type TEXT DEFAULT 'Tarea',
  max_grade NUMERIC DEFAULT 5.0,
  requires_file BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Tabla para asignaciones múltiples (estudiante individual, grupo, o todo el curso)
CREATE TABLE public.assignment_targets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  assignment_id UUID REFERENCES public.assignments(id) ON DELETE CASCADE,
  target_type TEXT CHECK (target_type IN ('course', 'group', 'student')),
  target_id UUID NOT NULL, 
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(assignment_id, target_type, target_id)
);

-- Tabla de Entregas (Submissions)
CREATE TABLE public.submissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  assignment_id UUID REFERENCES public.assignments(id) ON DELETE CASCADE,
  student_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
  content TEXT,
  file_url TEXT,
  status TEXT DEFAULT 'submitted' CHECK (status IN ('submitted', 'late', 'graded')),
  grade NUMERIC,
  feedback TEXT,
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(assignment_id, student_id) -- Solo 1 entrega por estudiante por tarea
);

-- ==============================================================================
-- 2. ÍNDICES DE RENDIMIENTO (Performance Indexes)
-- ==============================================================================
CREATE INDEX idx_assignments_teacher_id ON public.assignments(teacher_id);
CREATE INDEX idx_assignment_targets_assignment_id ON public.assignment_targets(assignment_id);
CREATE INDEX idx_assignment_targets_target_id ON public.assignment_targets(target_id);
CREATE INDEX idx_submissions_assignment_id ON public.submissions(assignment_id);
CREATE INDEX idx_submissions_student_id ON public.submissions(student_id);

-- ==============================================================================
-- 3. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

-- Habilitar RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.assignment_targets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.submissions ENABLE ROW LEVEL SECURITY;

---------------------------------------------------------
-- POLÍTICAS: PROFILES
---------------------------------------------------------
CREATE POLICY "Perfiles públicos para lectura" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "El usuario puede actualizar su perfil" ON public.profiles FOR UPDATE USING (auth.uid() = id);

---------------------------------------------------------
-- POLÍTICAS: ASSIGNMENTS
---------------------------------------------------------
-- Docente crea sus tareas
CREATE POLICY "Docentes pueden crear tareas" ON public.assignments 
  FOR INSERT WITH CHECK (
    auth.uid() = teacher_id AND 
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'teacher')
  );

-- Docente actualiza/elimina sus tareas
CREATE POLICY "Docentes pueden actualizar sus tareas" ON public.assignments FOR UPDATE USING (auth.uid() = teacher_id);
CREATE POLICY "Docentes pueden eliminar sus tareas" ON public.assignments FOR DELETE USING (auth.uid() = teacher_id);

-- VISIBILIDAD: Docente ve sus tareas. Estudiante ve si está asignado a él, o a su grupo.
CREATE POLICY "Lectura de tareas" ON public.assignments 
  FOR SELECT USING (
    teacher_id = auth.uid() OR 
    id IN (
      SELECT assignment_id FROM public.assignment_targets 
      WHERE 
        -- Asignado al estudiante directamente
        (target_type = 'student' AND target_id = auth.uid()) OR
        -- Asignado a un grupo del estudiante (requiere tabla group_members)
        (target_type = 'group' AND target_id IN (
           SELECT group_id FROM public.group_members WHERE student_id = auth.uid()
        ))
    )
  );

---------------------------------------------------------
-- POLÍTICAS: ASSIGNMENT_TARGETS
---------------------------------------------------------
-- Docente añade targets solo a SUS tareas
CREATE POLICY "Docentes asocian destinatarios a sus tareas" ON public.assignment_targets 
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM public.assignments 
      WHERE id = assignment_targets.assignment_id AND teacher_id = auth.uid()
    )
  );

-- Lectura de targets: El dueño de la tarea o el estudiante al que va dirigido
CREATE POLICY "Lectura de destinatarios" ON public.assignment_targets 
  FOR SELECT USING (
    target_id = auth.uid() OR
    EXISTS (
      SELECT 1 FROM public.assignments 
      WHERE id = assignment_targets.assignment_id AND teacher_id = auth.uid()
    )
  );

---------------------------------------------------------
-- POLÍTICAS: SUBMISSIONS
---------------------------------------------------------
-- Estudiante crea su entrega
CREATE POLICY "Estudiantes entregan sus tareas" ON public.submissions 
  FOR INSERT WITH CHECK (
    auth.uid() = student_id AND
    EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'student')
  );

-- Estudiante ve SUS entregas, Docente ve TODAS las entregas de SUS tareas
CREATE POLICY "Lectura de entregas" ON public.submissions 
  FOR SELECT USING (
    student_id = auth.uid() OR 
    EXISTS (
      SELECT 1 FROM public.assignments 
      WHERE id = submissions.assignment_id AND teacher_id = auth.uid()
    )
  );

-- Docente califica (actualiza) entregas
CREATE POLICY "Docentes califican entregas" ON public.submissions 
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.assignments 
      WHERE id = submissions.assignment_id AND teacher_id = auth.uid()
    )
  );

-- Estudiante actualiza su entrega SOLO si no ha sido calificada
CREATE POLICY "Estudiantes actualizan entregas sin nota" ON public.submissions 
  FOR UPDATE USING (
    auth.uid() = student_id AND status != 'graded'
  );
