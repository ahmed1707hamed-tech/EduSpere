import React, { createContext, useContext, useState, useEffect } from 'react';
import { 
  BrowserRouter as Router, 
  Routes, 
  Route, 
  Navigate, 
  Link, 
  useNavigate, 
  useParams 
} from 'react-router-dom';
import { 
  BookOpen, 
  GraduationCap, 
  Users, 
  Award, 
  Play, 
  FileText, 
  CheckCircle, 
  User, 
  LogOut, 
  Menu, 
  X, 
  Sun, 
  Moon, 
  ChevronRight, 
  Plus,
  Lock,
  ShieldAlert
} from 'lucide-react';
import { 
  BarChart, 
  Bar, 
  XAxis, 
  YAxis, 
  CartesianGrid, 
  Tooltip, 
  ResponsiveContainer,
  LineChart,
  Line
} from 'recharts';
import { apiUrl } from './api';

// ==========================================
// 1. CONTEXTS (AUTH & THEME)
// ==========================================

interface UserType {
  id: number;
  full_name: string;
  email: string;
  role: string;
  is_active: boolean;
}

interface AuthContextType {
  token: string | null;
  user: UserType | null;
  login: (token: string) => Promise<void>;
  logout: () => void;
  apiFetch: (url: string, options?: RequestInit) => Promise<any>;
  loading: boolean;
}

const AuthContext = createContext<AuthContextType | null>(null);

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within an AuthProvider');
  return context;
};

const DarkModeContext = createContext<{ dark: boolean; toggleDark: () => void } | null>(null);
export const useDarkMode = () => {
  const context = useContext(DarkModeContext);
  if (!context) throw new Error('useDarkMode must be used within a DarkModeProvider');
  return context;
};

// ==========================================
// 2. MAIN APP COMPONENT & PROVIDERS
// ==========================================

export default function App() {
  const [dark, setDark] = useState(() => localStorage.getItem('theme') === 'dark');
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('token'));
  const [user, setUser] = useState<UserType | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (dark) {
      document.documentElement.classList.add('dark');
    } else {
      document.documentElement.classList.remove('dark');
    }
    localStorage.setItem('theme', dark ? 'dark' : 'light');
  }, [dark]);

  const toggleDark = () => setDark(!dark);

  const apiFetch = async (url: string, options: RequestInit = {}) => {
    const headers = new Headers(options.headers || {});
    if (token) {
      headers.set('Authorization', `Bearer ${token}`);
    }
    if (!(options.body instanceof FormData) && !headers.has('Content-Type')) {
      headers.set('Content-Type', 'application/json');
    }

    const response = await fetch(apiUrl(url), { ...options, headers });
    
    if (response.status === 401) {
      logout();
      throw new Error('Unauthorized');
    }
    
    if (!response.ok) {
      const errData = await response.json().catch(() => ({}));
      throw new Error(errData.detail || 'API request failed');
    }
    
    if (response.status === 204) return null;
    return response.json();
  };

  const fetchProfile = async (currentToken: string) => {
    try {
      const data = await fetch(apiUrl('/auth/me'), {
        headers: { 'Authorization': `Bearer ${currentToken}` }
      });
      if (data.ok) {
        const profile = await data.json();
        setUser(profile);
      } else {
        logout();
      }
    } catch (e) {
      logout();
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (token) {
      fetchProfile(token);
    } else {
      setLoading(false);
    }
  }, [token]);

  const login = async (newToken: string) => {
    localStorage.setItem('token', newToken);
    setToken(newToken);
    setLoading(true);
    await fetchProfile(newToken);
  };

  const logout = () => {
    localStorage.removeItem('token');
    setToken(null);
    setUser(null);
    setLoading(false);
  };

  return (
    <AuthContext.Provider value={{ token, user, login, logout, apiFetch, loading }}>
      <DarkModeContext.Provider value={{ dark, toggleDark }}>
        <Router>
          <div className="min-h-screen bg-slate-50 text-slate-950 dark:bg-slate-950 dark:text-slate-50 transition-colors duration-200">
            <Routes>
              <Route path="/" element={<LandingPage />} />
              <Route path="/login" element={<LoginPage />} />
              <Route path="/register" element={<RegisterPage />} />
              
              {/* Protected Routes */}
              <Route path="/dashboard" element={<ProtectedRoute><DashboardRouter /></ProtectedRoute>} />
              <Route path="/courses" element={<ProtectedRoute><CourseCatalogPage /></ProtectedRoute>} />
              <Route path="/courses/:courseId" element={<ProtectedRoute><CourseViewerPage /></ProtectedRoute>} />
              <Route path="/profile" element={<ProtectedRoute><ProfilePage /></ProtectedRoute>} />

              <Route path="*" element={<Navigate to="/" />} />
            </Routes>
          </div>
        </Router>
      </DarkModeContext.Provider>
    </AuthContext.Provider>
  );
}

// Protected Route Guard
function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { token, loading } = useAuth();
  if (loading) return <div className="flex h-screen items-center justify-center">Loading...</div>;
  if (!token) return <Navigate to="/login" />;
  return <>{children}</>;
}

// Router to direct roles to their dashboards
function DashboardRouter() {
  const { user } = useAuth();
  if (user?.role === 'admin') return <AdminDashboard />;
  if (user?.role === 'instructor') return <InstructorDashboard />;
  return <StudentDashboard />;
}

// ==========================================
// 3. LAYOUT COMPONENTS (NAVBAR & SIDEBAR)
// ==========================================

function Layout({ children }: { children: React.ReactNode }) {
  const { user, logout } = useAuth();
  const { dark, toggleDark } = useDarkMode();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  return (
    <div className="flex min-h-screen flex-col">
      {/* Header */}
      <header className="sticky top-0 z-40 border-b border-slate-200 bg-white/80 backdrop-blur-md dark:border-slate-800 dark:bg-slate-900/80">
        <div className="flex h-16 items-center justify-between px-6">
          <div className="flex items-center gap-2">
            <GraduationCap className="h-8 w-8 text-indigo-600 dark:text-indigo-400" />
            <span className="text-xl font-bold tracking-wider text-gradient">EduSphere</span>
          </div>
          
          {/* Desktop Navigation */}
          <nav className="hidden md:flex items-center gap-6">
            <Link to="/dashboard" className="text-sm font-medium hover:text-indigo-600 dark:hover:text-indigo-400">Dashboard</Link>
            <Link to="/courses" className="text-sm font-medium hover:text-indigo-600 dark:hover:text-indigo-400">All Courses</Link>
            <Link to="/profile" className="text-sm font-medium hover:text-indigo-600 dark:hover:text-indigo-400">Profile</Link>
            
            <span className="h-5 w-px bg-slate-200 dark:bg-slate-800"></span>

            <button onClick={toggleDark} className="rounded-full p-2 hover:bg-slate-100 dark:hover:bg-slate-800">
              {dark ? <Sun className="h-5 w-5 text-amber-500" /> : <Moon className="h-5 w-5 text-slate-500" />}
            </button>

            <div className="flex items-center gap-3">
              <div className="flex flex-col text-right">
                <span className="text-sm font-semibold">{user?.full_name}</span>
                <span className="text-xs text-slate-500 capitalize">{user?.role}</span>
              </div>
              <button onClick={logout} className="rounded-full p-2 hover:bg-red-50 dark:hover:bg-red-900/20 text-red-500">
                <LogOut className="h-5 w-5" />
              </button>
            </div>
          </nav>

          {/* Mobile Menu Toggle */}
          <button onClick={() => setMobileMenuOpen(!mobileMenuOpen)} className="md:hidden rounded-lg p-2 hover:bg-slate-100 dark:hover:bg-slate-800">
            {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
          </button>
        </div>

        {/* Mobile Navigation Dropdown */}
        {mobileMenuOpen && (
          <div className="border-t border-slate-200 bg-white px-6 py-4 dark:border-slate-800 dark:bg-slate-900 md:hidden flex flex-col gap-4">
            <Link to="/dashboard" onClick={() => setMobileMenuOpen(false)} className="text-sm font-medium">Dashboard</Link>
            <Link to="/courses" onClick={() => setMobileMenuOpen(false)} className="text-sm font-medium">All Courses</Link>
            <Link to="/profile" onClick={() => setMobileMenuOpen(false)} className="text-sm font-medium">Profile</Link>
            <hr className="border-slate-200 dark:border-slate-800" />
            <div className="flex items-center justify-between">
              <span className="text-sm font-medium">Dark Mode</span>
              <button onClick={toggleDark} className="rounded-full p-2 hover:bg-slate-100 dark:hover:bg-slate-800">
                {dark ? <Sun className="h-5 w-5 text-amber-500" /> : <Moon className="h-5 w-5" />}
              </button>
            </div>
            <div className="flex items-center justify-between pt-2">
              <div className="flex flex-col">
                <span className="text-sm font-semibold">{user?.full_name}</span>
                <span className="text-xs text-slate-500 capitalize">{user?.role}</span>
              </div>
              <button onClick={logout} className="flex items-center gap-2 rounded-lg bg-red-50 px-3 py-2 text-sm font-medium text-red-600 dark:bg-red-950/30 dark:text-red-400">
                <LogOut className="h-4 w-4" /> Log Out
              </button>
            </div>
          </div>
        )}
      </header>

      {/* Content */}
      <main className="flex-1 px-6 py-8 max-w-7xl mx-auto w-full">
        {children}
      </main>
    </div>
  );
}

// ==========================================
// 4. PAGES (PUBLIC & AUTH)
// ==========================================

// Landing Page
function LandingPage() {
  const { token } = useAuth();
  return (
    <div className="flex min-h-screen flex-col bg-slate-950 text-white">
      {/* Navbar */}
      <header className="flex h-20 items-center justify-between px-8 border-b border-white/5 bg-slate-950/50 backdrop-blur-md sticky top-0 z-50">
        <div className="flex items-center gap-2">
          <GraduationCap className="h-8 w-8 text-indigo-500" />
          <span className="text-xl font-bold tracking-wider text-gradient">EduSphere</span>
        </div>
        <div className="flex items-center gap-4">
          {token ? (
            <Link to="/dashboard" className="rounded-xl bg-indigo-600 px-6 py-2.5 text-sm font-semibold hover:bg-indigo-500 transition-all duration-200 shadow-lg shadow-indigo-600/30">
              Go to Dashboard
            </Link>
          ) : (
            <>
              <Link to="/login" className="text-sm font-semibold hover:text-indigo-400 transition-colors">Sign In</Link>
              <Link to="/register" className="rounded-xl bg-white text-slate-950 px-6 py-2.5 text-sm font-semibold hover:bg-slate-150 transition-all duration-200 shadow-lg shadow-white/10">
                Register
              </Link>
            </>
          )}
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative flex flex-1 flex-col items-center justify-center px-6 text-center py-24 overflow-hidden">
        <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(99,102,241,0.15)_0,transparent_60%)]"></div>
        <div className="absolute top-1/4 left-1/4 h-72 w-72 rounded-full bg-indigo-600/10 blur-3xl"></div>
        <div className="absolute bottom-1/4 right-1/4 h-72 w-72 rounded-full bg-purple-600/10 blur-3xl"></div>

        <div className="z-10 max-w-3xl">
          <span className="inline-flex items-center gap-1.5 rounded-full bg-indigo-500/10 px-4 py-1.5 text-xs font-semibold text-indigo-400 border border-indigo-500/20">
            Now Powered by Microservices Architecture
          </span>
          <h1 className="mt-6 text-5xl font-extrabold tracking-tight sm:text-6xl md:text-7xl leading-tight">
            Learn Without Limits, <br />
            <span className="text-gradient">Teach Without Boundaries</span>
          </h1>
          <p className="mt-6 text-lg text-slate-400 max-w-2xl mx-auto leading-relaxed">
            EduSphere is a next-generation Cloud-Native LMS. Experience high performance, role-based workflows, quizzes with automated grading, and media streaming.
          </p>
          <div className="mt-10 flex flex-wrap justify-center gap-4">
            <Link to="/register" className="rounded-xl bg-indigo-600 px-8 py-4 text-base font-semibold hover:bg-indigo-500 transition-all duration-200 shadow-xl shadow-indigo-600/30">
              Get Started for Free
            </Link>
            <Link to="/login" className="rounded-xl border border-white/10 bg-white/5 px-8 py-4 text-base font-semibold hover:bg-white/10 transition-all duration-200">
              Explore Courses
            </Link>
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="px-8 py-20 bg-slate-900/50 border-t border-white/5">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-3xl font-bold text-center mb-12">Features Designed for Modern Learning</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="border border-white/5 bg-white/5 p-8 rounded-2xl">
              <BookOpen className="h-10 w-10 text-indigo-400 mb-4" />
              <h3 className="text-lg font-bold mb-2">Flexible Course Creator</h3>
              <p className="text-slate-400 text-sm leading-relaxed">Instructors can build nested modules, lessons, and upload video or PDF resources to S3 compatible object storage.</p>
            </div>
            <div className="border border-white/5 bg-white/5 p-8 rounded-2xl">
              <Award className="h-10 w-10 text-purple-400 mb-4" />
              <h3 className="text-lg font-bold mb-2">Automated Quizzes</h3>
              <p className="text-slate-400 text-sm leading-relaxed">Assess student knowledge with multiple choice quizzes. Get graded instantly and download certificates on passing.</p>
            </div>
            <div className="border border-white/5 bg-white/5 p-8 rounded-2xl">
              <Users className="h-10 w-10 text-pink-400 mb-4" />
              <h3 className="text-lg font-bold mb-2">Role-Based Access</h3>
              <p className="text-slate-400 text-sm leading-relaxed">Dedicated interfaces and dashboards optimized for Students, Instructors, and System Administrators.</p>
            </div>
          </div>
        </div>
      </section>
    </div>
  );
}

// Login Page
function LoginPage() {
  const { login } = useAuth();
  const navigate = useNavigate();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      const res = await fetch(apiUrl('/auth/login'), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password })
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.detail || 'Login failed');
      }
      const data = await res.json();
      await login(data.access_token);
      navigate('/dashboard');
    } catch (err: any) {
      setError(err.message || 'Incorrect email or password');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center px-4 bg-slate-950 text-white relative overflow-hidden">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(99,102,241,0.1)_0,transparent_50%)]"></div>
      <div className="z-10 w-full max-w-md rounded-2xl border border-white/10 bg-white/5 p-8 shadow-2xl backdrop-blur-md">
        <div className="flex flex-col items-center mb-6">
          <GraduationCap className="h-10 w-10 text-indigo-500" />
          <h2 className="text-2xl font-bold mt-2">Welcome Back</h2>
          <p className="text-sm text-slate-400">Sign in to your EduSphere account</p>
        </div>

        {error && (
          <div className="mb-4 rounded-lg bg-red-500/10 border border-red-500/20 p-3 text-sm text-red-400 flex items-center gap-2">
            <ShieldAlert className="h-4 w-4 shrink-0" />
            <span>{error}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Email Address</label>
            <input 
              type="email" 
              required 
              value={email} 
              onChange={e => setEmail(e.target.value)}
              className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none"
              placeholder="you@example.com"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Password</label>
            <input 
              type="password" 
              required 
              value={password} 
              onChange={e => setPassword(e.target.value)}
              className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none"
              placeholder="••••••••"
            />
          </div>
          <button 
            type="submit" 
            disabled={submitting}
            className="mt-2 w-full rounded-xl bg-indigo-600 py-3.5 text-sm font-semibold hover:bg-indigo-500 transition-all duration-200 shadow-lg shadow-indigo-600/30 disabled:opacity-50"
          >
            {submitting ? 'Signing In...' : 'Sign In'}
          </button>
        </form>

        <p className="mt-6 text-center text-xs text-slate-400">
          Don't have an account?{' '}
          <Link to="/register" className="font-semibold text-indigo-400 hover:underline">Register here</Link>
        </p>
      </div>
    </div>
  );
}

// Register Page
function RegisterPage() {
  const navigate = useNavigate();
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [role, setRole] = useState('student');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [submitting, setSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');
    setSubmitting(true);
    try {
      const res = await fetch(apiUrl('/auth/register'), {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ full_name: fullName, email, password, role })
      });
      if (!res.ok) {
        const err = await res.json().catch(() => ({}));
        throw new Error(err.detail || 'Registration failed');
      }
      setSuccess('Account created successfully! Redirecting to login...');
      setTimeout(() => navigate('/login'), 2000);
    } catch (err: any) {
      setError(err.message || 'Registration failed');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center px-4 bg-slate-950 text-white relative overflow-hidden">
      <div className="absolute inset-0 bg-[radial-gradient(circle_at_center,rgba(99,102,241,0.1)_0,transparent_50%)]"></div>
      <div className="z-10 w-full max-w-md rounded-2xl border border-white/10 bg-white/5 p-8 shadow-2xl backdrop-blur-md">
        <div className="flex flex-col items-center mb-6">
          <GraduationCap className="h-10 w-10 text-indigo-500" />
          <h2 className="text-2xl font-bold mt-2">Create Account</h2>
          <p className="text-sm text-slate-400">Join EduSphere learning network</p>
        </div>

        {error && (
          <div className="mb-4 rounded-lg bg-red-500/10 border border-red-500/20 p-3 text-sm text-red-400 flex items-center gap-2">
            <ShieldAlert className="h-4 w-4 shrink-0" />
            <span>{error}</span>
          </div>
        )}

        {success && (
          <div className="mb-4 rounded-lg bg-green-500/10 border border-green-500/20 p-3 text-sm text-green-400 flex items-center gap-2">
            <CheckCircle className="h-4 w-4 shrink-0" />
            <span>{success}</span>
          </div>
        )}

        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Full Name</label>
            <input 
              type="text" 
              required 
              value={fullName} 
              onChange={e => setFullName(e.target.value)}
              className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none"
              placeholder="John Doe"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Email Address</label>
            <input 
              type="email" 
              required 
              value={email} 
              onChange={e => setEmail(e.target.value)}
              className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none"
              placeholder="you@example.com"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Password</label>
            <input 
              type="password" 
              required 
              value={password} 
              onChange={e => setPassword(e.target.value)}
              className="w-full rounded-xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white placeholder-slate-500 focus:border-indigo-500 focus:outline-none"
              placeholder="•••••••• (min 6 characters)"
            />
          </div>
          <div>
            <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Register As</label>
            <select 
              value={role} 
              onChange={e => setRole(e.target.value)}
              className="w-full rounded-xl border border-white/10 bg-slate-900 px-4 py-3 text-sm text-white focus:border-indigo-500 focus:outline-none"
            >
              <option value="student">Student</option>
              <option value="instructor">Instructor</option>
            </select>
          </div>
          <button 
            type="submit" 
            disabled={submitting}
            className="mt-2 w-full rounded-xl bg-indigo-600 py-3.5 text-sm font-semibold hover:bg-indigo-500 transition-all duration-200 shadow-lg shadow-indigo-600/30 disabled:opacity-50"
          >
            {submitting ? 'Registering...' : 'Register'}
          </button>
        </form>

        <p className="mt-6 text-center text-xs text-slate-400">
          Already have an account?{' '}
          <Link to="/login" className="font-semibold text-indigo-400 hover:underline">Sign in here</Link>
        </p>
      </div>
    </div>
  );
}

// ==========================================
// 5. DASHBOARDS (ROLE-SPECIFIC)
// ==========================================

// Student Dashboard
function StudentDashboard() {
  const { apiFetch, user } = useAuth();
  const [enrolled, setEnrolled] = useState<any[]>([]);
  const [certificates, setCertificates] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      apiFetch('/api/courses/enrolled/me'),
      apiFetch('/api/quizzes/certificates/me')
    ]).then(([coursesRes, certsRes]) => {
      setEnrolled(coursesRes || []);
      setCertificates(certsRes || []);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, []);

  if (loading) return <Layout><div className="text-center">Loading Dashboard...</div></Layout>;

  return (
    <Layout>
      <div className="flex flex-col gap-8">
        {/* Welcome Block */}
        <div className="rounded-2xl bg-gradient-to-r from-indigo-600 to-purple-600 p-8 text-white shadow-xl">
          <h1 className="text-3xl font-extrabold">Welcome back, {user?.full_name}! 👋</h1>
          <p className="mt-2 text-indigo-100 max-w-xl">Continue where you left off or explore new courses to expand your knowledge.</p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div className="glass-panel rounded-2xl p-6 shadow-sm flex items-center gap-4">
            <div className="rounded-xl bg-indigo-500/10 p-3 text-indigo-600 dark:text-indigo-400"><BookOpen className="h-6 w-6" /></div>
            <div>
              <span className="text-sm text-slate-500">Enrolled Courses</span>
              <h3 className="text-2xl font-bold">{enrolled.length}</h3>
            </div>
          </div>
          <div className="glass-panel rounded-2xl p-6 shadow-sm flex items-center gap-4">
            <div className="rounded-xl bg-purple-500/10 p-3 text-purple-600 dark:text-purple-400"><Award className="h-6 w-6" /></div>
            <div>
              <span className="text-sm text-slate-500">Certificates Earned</span>
              <h3 className="text-2xl font-bold">{certificates.length}</h3>
            </div>
          </div>
          <div className="glass-panel rounded-2xl p-6 shadow-sm flex items-center gap-4">
            <div className="rounded-xl bg-green-500/10 p-3 text-green-600 dark:text-green-400"><CheckCircle className="h-6 w-6" /></div>
            <div>
              <span className="text-sm text-slate-500">Completed Lessons</span>
              <h3 className="text-2xl font-bold">12</h3>
            </div>
          </div>
        </div>

        {/* Course Cards & Certificates */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Courses List */}
          <div className="lg:col-span-2 flex flex-col gap-4">
            <h2 className="text-xl font-bold">My Courses</h2>
            {enrolled.length === 0 ? (
              <div className="rounded-2xl border border-dashed border-slate-200 p-8 text-center dark:border-slate-800">
                <p className="text-slate-500 text-sm mb-4">You are not enrolled in any courses yet.</p>
                <Link to="/courses" className="rounded-xl bg-indigo-600 px-6 py-2 text-sm font-semibold text-white hover:bg-indigo-500">
                  Browse Catalog
                </Link>
              </div>
            ) : (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {enrolled.map(c => (
                  <div key={c.id} className="glass-panel rounded-2xl overflow-hidden shadow-sm flex flex-col hover:shadow-md transition-shadow">
                    <div className="h-3 bg-gradient-to-r from-indigo-500 to-purple-500"></div>
                    <div className="p-6 flex flex-col flex-1">
                      <span className="text-xs font-semibold text-indigo-500 uppercase tracking-wider mb-2">{c.category}</span>
                      <h3 className="text-lg font-bold leading-snug mb-2">{c.title}</h3>
                      <p className="text-slate-500 text-xs mb-6 line-clamp-2">{c.description}</p>
                      <div className="mt-auto flex items-center justify-between">
                        <span className="text-xs text-slate-400">Enrolled recently</span>
                        <Link to={`/courses/${c.id}`} className="flex items-center gap-1 text-sm font-semibold text-indigo-600 hover:text-indigo-500 dark:text-indigo-400">
                          Resume <ChevronRight className="h-4 w-4" />
                        </Link>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Certificates Panel */}
          <div className="flex flex-col gap-4">
            <h2 className="text-xl font-bold">My Certificates</h2>
            {certificates.length === 0 ? (
              <div className="rounded-2xl border border-dashed border-slate-200 p-8 text-center dark:border-slate-800 flex flex-col items-center">
                <Award className="h-10 w-10 text-slate-300 dark:text-slate-700 mb-2" />
                <p className="text-slate-500 text-xs">Pass course final quizzes to earn certificates.</p>
              </div>
            ) : (
              <div className="flex flex-col gap-4">
                {certificates.map(cert => (
                  <div key={cert.id} className="glass-panel rounded-2xl p-4 flex items-center justify-between shadow-sm">
                    <div className="flex items-center gap-3">
                      <Award className="h-8 w-8 text-amber-500" />
                      <div className="flex flex-col">
                        <span className="text-sm font-bold">Course Completed</span>
                        <span className="text-[10px] font-mono text-slate-400">{cert.certificate_code}</span>
                      </div>
                    </div>
                    <span className="text-xs text-slate-500">{new Date(cert.issue_date).toLocaleDateString()}</span>
                  </div>
                ))}
              </div>
            )}
          </div>
        </div>
      </div>
    </Layout>
  );
}

// Instructor Dashboard
function InstructorDashboard() {
  const { apiFetch, user } = useAuth();
  const [courses, setCourses] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  
  // State for creating a course
  const [showCreateModal, setShowCreateModal] = useState(false);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState('General');
  const [price, setPrice] = useState('0');

  const fetchCourses = () => {
    apiFetch(`/api/courses/?is_published=false`).then(res => {
      // Filter only this instructor's courses
      const instructorCourses = (res || []).filter((c: any) => c.instructor_id === user?.id);
      setCourses(instructorCourses);
      setLoading(false);
    }).catch(() => setLoading(false));
  };

  useEffect(() => {
    fetchCourses();
  }, []);

  const handleCreateCourse = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await apiFetch('/api/courses/', {
        method: 'POST',
        body: JSON.stringify({ title, description, category, price: parseFloat(price) })
      });
      setTitle('');
      setDescription('');
      setCategory('General');
      setPrice('0');
      setShowCreateModal(false);
      fetchCourses();
    } catch (err: any) {
      alert(err.message || 'Failed to create course');
    }
  };

  const chartData = [
    { name: 'Jan', students: 12 },
    { name: 'Feb', students: 25 },
    { name: 'Mar', students: 45 },
    { name: 'Apr', students: 80 },
    { name: 'May', students: 110 },
    { name: 'Jun', students: 145 },
  ];

  if (loading) return <Layout><div className="text-center">Loading Instructor Dashboard...</div></Layout>;

  return (
    <Layout>
      <div className="flex flex-col gap-8">
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-extrabold">Instructor Portal</h1>
            <p className="text-slate-500 text-sm mt-1">Manage your courses, content, and track student enrollment.</p>
          </div>
          <button 
            onClick={() => setShowCreateModal(true)} 
            className="flex items-center gap-2 rounded-xl bg-indigo-600 px-6 py-3 text-sm font-semibold text-white hover:bg-indigo-500 shadow-lg shadow-indigo-600/20"
          >
            <Plus className="h-5 w-5" /> New Course
          </button>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div className="glass-panel rounded-2xl p-6 shadow-sm">
            <span className="text-xs text-slate-400 uppercase font-semibold">Total Courses</span>
            <h3 className="text-3xl font-bold mt-1">{courses.length}</h3>
          </div>
          <div className="glass-panel rounded-2xl p-6 shadow-sm">
            <span className="text-xs text-slate-400 uppercase font-semibold">Active Students</span>
            <h3 className="text-3xl font-bold mt-1">145</h3>
          </div>
          <div className="glass-panel rounded-2xl p-6 shadow-sm">
            <span className="text-xs text-slate-400 uppercase font-semibold">Total Revenue</span>
            <h3 className="text-3xl font-bold mt-1">$4,850</h3>
          </div>
          <div className="glass-panel rounded-2xl p-6 shadow-sm">
            <span className="text-xs text-slate-400 uppercase font-semibold">Average Rating</span>
            <h3 className="text-3xl font-bold mt-1">4.8 ★</h3>
          </div>
        </div>

        {/* Charts & Course List */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Course List */}
          <div className="lg:col-span-2 flex flex-col gap-4">
            <h2 className="text-xl font-bold">My Created Courses</h2>
            {courses.length === 0 ? (
              <div className="rounded-2xl border border-dashed border-slate-200 p-12 text-center dark:border-slate-800">
                <BookOpen className="h-12 w-12 text-slate-300 dark:text-slate-700 mx-auto mb-3" />
                <p className="text-slate-500 mb-4">You haven't created any courses yet.</p>
                <button onClick={() => setShowCreateModal(true)} className="rounded-xl bg-indigo-600 px-6 py-2 text-sm font-semibold text-white">
                  Create First Course
                </button>
              </div>
            ) : (
              <div className="flex flex-col gap-4">
                {courses.map(c => (
                  <div key={c.id} className="glass-panel rounded-2xl p-6 flex flex-col md:flex-row justify-between items-start md:items-center gap-4">
                    <div>
                      <div className="flex items-center gap-2">
                        <span className={`rounded-full px-2 py-0.5 text-[10px] font-bold uppercase ${c.is_published ? 'bg-green-100 text-green-700 dark:bg-green-950/40 dark:text-green-400' : 'bg-amber-100 text-amber-700 dark:bg-amber-950/40 dark:text-amber-400'}`}>
                          {c.is_published ? 'Published' : 'Draft'}
                        </span>
                        <span className="text-xs text-slate-400">{c.category}</span>
                      </div>
                      <h3 className="text-lg font-bold mt-2">{c.title}</h3>
                      <p className="text-slate-500 text-xs mt-1 line-clamp-1">{c.description}</p>
                    </div>
                    <div className="flex items-center gap-3 w-full md:w-auto">
                      <Link to={`/courses/${c.id}`} className="flex-1 md:flex-none text-center rounded-xl border border-slate-200 dark:border-slate-800 px-4 py-2 text-xs font-semibold hover:bg-slate-50 dark:hover:bg-slate-800">
                        Course Builder
                      </Link>
                      <span className="text-sm font-bold shrink-0">${c.price}</span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {/* Student Growth Chart */}
          <div className="glass-panel rounded-2xl p-6 shadow-sm flex flex-col gap-4">
            <h2 className="text-lg font-bold">Student Growth</h2>
            <div className="h-60 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#334155" opacity={0.1} />
                  <XAxis dataKey="name" stroke="#64748b" fontSize={11} />
                  <YAxis stroke="#64748b" fontSize={11} />
                  <Tooltip contentStyle={{ background: '#1e293b', border: 'none', borderRadius: '8px' }} />
                  <Line type="monotone" dataKey="students" stroke="#6366f1" strokeWidth={3} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        {/* Create Course Modal */}
        {showCreateModal && (
          <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/60 backdrop-blur-sm px-4">
            <div className="w-full max-w-lg rounded-2xl bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-800 p-8 shadow-2xl">
              <div className="flex items-center justify-between mb-6">
                <h3 className="text-xl font-bold">Create New Course</h3>
                <button onClick={() => setShowCreateModal(false)} className="rounded-lg p-1.5 hover:bg-slate-100 dark:hover:bg-slate-800">
                  <X className="h-5 w-5" />
                </button>
              </div>
              
              <form onSubmit={handleCreateCourse} className="flex flex-col gap-4">
                <div>
                  <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Course Title</label>
                  <input 
                    type="text" 
                    required 
                    value={title} 
                    onChange={e => setTitle(e.target.value)}
                    className="w-full rounded-xl border border-slate-200 dark:border-slate-800 bg-transparent px-4 py-3 text-sm focus:border-indigo-500 focus:outline-none"
                    placeholder="e.g. Mastering Advanced Python"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Description</label>
                  <textarea 
                    value={description} 
                    onChange={e => setDescription(e.target.value)}
                    className="w-full rounded-xl border border-slate-200 dark:border-slate-800 bg-transparent px-4 py-3 text-sm focus:border-indigo-500 focus:outline-none"
                    placeholder="Describe what students will learn..."
                    rows={3}
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Category</label>
                    <input 
                      type="text" 
                      value={category} 
                      onChange={e => setCategory(e.target.value)}
                      className="w-full rounded-xl border border-slate-200 dark:border-slate-800 bg-transparent px-4 py-3 text-sm focus:border-indigo-500 focus:outline-none"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Price ($)</label>
                    <input 
                      type="number" 
                      value={price} 
                      onChange={e => setPrice(e.target.value)}
                      className="w-full rounded-xl border border-slate-200 dark:border-slate-800 bg-transparent px-4 py-3 text-sm focus:border-indigo-500 focus:outline-none"
                    />
                  </div>
                </div>
                <button type="submit" className="mt-4 w-full rounded-xl bg-indigo-600 py-3.5 text-sm font-semibold text-white hover:bg-indigo-500 shadow-lg shadow-indigo-600/20">
                  Create Course
                </button>
              </form>
            </div>
          </div>
        )}
      </div>
    </Layout>
  );
}

// Admin Dashboard
function AdminDashboard() {
  const { apiFetch } = useAuth();
  const [users, setUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiFetch('/auth/users').then(res => {
      setUsers(res || []);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, []);

  const chartData = [
    { name: 'Mon', active: 45 },
    { name: 'Tue', active: 60 },
    { name: 'Wed', active: 90 },
    { name: 'Thu', active: 85 },
    { name: 'Fri', active: 110 },
    { name: 'Sat', active: 75 },
    { name: 'Sun', active: 65 },
  ];

  if (loading) return <Layout><div className="text-center">Loading Admin Panel...</div></Layout>;

  return (
    <Layout>
      <div className="flex flex-col gap-8">
        <div>
          <h1 className="text-3xl font-extrabold">System Administration</h1>
          <p className="text-slate-500 text-sm mt-1">Monitor services, manage users, and inspect application metrics.</p>
        </div>

        {/* Service Status Map */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
          <div className="glass-panel rounded-2xl p-6 shadow-sm flex justify-between items-center">
            <span className="text-sm font-semibold">Auth Service</span>
            <span className="h-3 w-3 rounded-full bg-green-500 shadow-[0_0_8px_#22c55e]"></span>
          </div>
          <div className="glass-panel rounded-2xl p-6 shadow-sm flex justify-between items-center">
            <span className="text-sm font-semibold">Course Service</span>
            <span className="h-3 w-3 rounded-full bg-green-500 shadow-[0_0_8px_#22c55e]"></span>
          </div>
          <div className="glass-panel rounded-2xl p-6 shadow-sm flex justify-between items-center">
            <span className="text-sm font-semibold">Content Service</span>
            <span className="h-3 w-3 rounded-full bg-green-500 shadow-[0_0_8px_#22c55e]"></span>
          </div>
          <div className="glass-panel rounded-2xl p-6 shadow-sm flex justify-between items-center">
            <span className="text-sm font-semibold">Quiz & Progress</span>
            <span className="h-3 w-3 rounded-full bg-green-500 shadow-[0_0_8px_#22c55e]"></span>
          </div>
        </div>

        {/* Main Layout Grid */}
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* User Management */}
          <div className="lg:col-span-2 flex flex-col gap-4">
            <h2 className="text-xl font-bold">Registered Users ({users.length})</h2>
            <div className="glass-panel rounded-2xl overflow-hidden shadow-sm border border-slate-200 dark:border-slate-800">
              <div className="overflow-x-auto">
                <table className="w-full text-left text-sm">
                  <thead className="bg-slate-100/50 dark:bg-slate-800/40 text-slate-500 uppercase text-xs">
                    <tr>
                      <th className="p-4">Name</th>
                      <th className="p-4">Email</th>
                      <th className="p-4">Role</th>
                      <th className="p-4">Status</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-200 dark:divide-slate-800">
                    {users.map(u => (
                      <tr key={u.id} className="hover:bg-slate-50/50 dark:hover:bg-slate-800/20">
                        <td className="p-4 font-semibold">{u.full_name}</td>
                        <td className="p-4 text-slate-500">{u.email}</td>
                        <td className="p-4 capitalize">{u.role}</td>
                        <td className="p-4">
                          <span className="inline-flex rounded-full bg-green-100 px-2 py-0.5 text-[10px] font-bold text-green-800 dark:bg-green-950/30 dark:text-green-400">
                            Active
                          </span>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>

          {/* Traffic Monitor */}
          <div className="glass-panel rounded-2xl p-6 shadow-sm flex flex-col gap-4">
            <h2 className="text-lg font-bold">Active Sessions (Daily)</h2>
            <div className="h-60 w-full">
              <ResponsiveContainer width="100%" height="100%">
                <BarChart data={chartData}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#334155" opacity={0.1} />
                  <XAxis dataKey="name" stroke="#64748b" fontSize={11} />
                  <YAxis stroke="#64748b" fontSize={11} />
                  <Tooltip contentStyle={{ background: '#1e293b', border: 'none', borderRadius: '8px' }} />
                  <Bar dataKey="active" fill="#6366f1" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>
      </div>
    </Layout>
  );
}

// ==========================================
// 6. COURSE CATALOG PAGE
// ==========================================

function CourseCatalogPage() {
  const { apiFetch } = useAuth();
  const [courses, setCourses] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiFetch('/api/courses/').then(res => {
      setCourses(res || []);
      setLoading(false);
    }).catch(() => setLoading(false));
  }, []);

  const handleEnroll = async (courseId: number) => {
    try {
      await apiFetch(`/api/courses/${courseId}/enroll`, { method: 'POST' });
      alert('Enrolled successfully!');
      window.location.reload();
    } catch (e: any) {
      alert(e.message || 'Failed to enroll');
    }
  };

  if (loading) return <Layout><div className="text-center">Loading Course Catalog...</div></Layout>;

  return (
    <Layout>
      <div className="flex flex-col gap-8">
        <div>
          <h1 className="text-3xl font-extrabold">Course Catalog</h1>
          <p className="text-slate-500 text-sm mt-1">Browse and enroll in next-generation courses.</p>
        </div>

        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {courses.length === 0 ? (
            <div className="col-span-3 text-center text-slate-500">No published courses available.</div>
          ) : (
            courses.map(c => (
              <div key={c.id} className="glass-panel rounded-2xl overflow-hidden shadow-sm flex flex-col hover:shadow-md transition-shadow">
                <div className="h-4 bg-gradient-to-r from-indigo-500 to-purple-500"></div>
                <div className="p-6 flex flex-col flex-1">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-xs font-semibold text-indigo-500 uppercase tracking-wider">{c.category}</span>
                    <span className="text-sm font-bold text-slate-700 dark:text-slate-300">${c.price}</span>
                  </div>
                  <h3 className="text-lg font-bold leading-snug mb-2">{c.title}</h3>
                  <p className="text-slate-500 text-sm mb-6 line-clamp-3">{c.description}</p>
                  <button 
                    onClick={() => handleEnroll(c.id)}
                    className="mt-auto w-full rounded-xl bg-indigo-600 py-3 text-sm font-semibold text-white hover:bg-indigo-500 shadow-md shadow-indigo-600/10"
                  >
                    Enroll Now
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </Layout>
  );
}

// ==========================================
// 7. COURSE VIEWER & PLAYER PAGE
// ==========================================

function CourseViewerPage() {
  const { courseId } = useParams();
  const { apiFetch, user } = useAuth();
  const [course, setCourse] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [activeLesson, setActiveLesson] = useState<any>(null);
  const [videoUrl, setVideoUrl] = useState<string>('');
  
  // Quiz states
  const [quiz, setQuiz] = useState<any>(null);
  const [selectedAnswers, setSelectedAnswers] = useState<{ [key: number]: number }>({});
  const [quizSubmitted, setQuizSubmitted] = useState(false);
  const [quizResult, setQuizResult] = useState<any>(null);

  // Instructor builder states
  const [newModuleName, setNewModuleName] = useState('');
  const [newLessonTitle, setNewLessonTitle] = useState('');
  const [newLessonType, setNewLessonType] = useState('video');
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  const [uploading, setUploading] = useState(false);

  const fetchCourseDetails = () => {
    apiFetch(`/api/courses/${courseId}`).then(res => {
      setCourse(res);
      setLoading(false);
      // Auto-select first lesson if available
      if (res?.modules?.[0]?.lessons?.[0] && !activeLesson) {
        handleSelectLesson(res.modules[0].lessons[0]);
      }
    }).catch(() => setLoading(false));
  };

  useEffect(() => {
    fetchCourseDetails();
  }, [courseId]);

  const handleSelectLesson = async (lesson: any) => {
    setActiveLesson(lesson);
    setVideoUrl('');
    setQuiz(null);
    setQuizSubmitted(false);
    setQuizResult(null);
    setSelectedAnswers({});

    if (lesson.content_type === 'video') {
      // For simplicity, we check if S3 url exists and mock it, or if it is uploaded, we fetch signed URL.
      // If the lesson.content_url contains a number, it might be a media_id
      const mediaId = parseInt(lesson.content_url);
      if (!isNaN(mediaId)) {
        try {
          const signRes = await apiFetch(`/api/content/url/${mediaId}`);
          setVideoUrl(signRes.url);
        } catch (e) {
          // Fallback mockup video url
          setVideoUrl('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4');
        }
      } else {
        setVideoUrl('https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4');
      }
    } else if (lesson.content_type === 'quiz') {
      // In this system, quiz is mapped by lesson.content_url which points to the quiz_id
      const quizId = parseInt(lesson.content_url);
      if (!isNaN(quizId)) {
        apiFetch(`/api/quizzes/${quizId}`).then(res => {
          setQuiz(res);
        }).catch(() => {});
      }
    }
  };

  // Add Module (Instructor only)
  const handleAddModule = async () => {
    if (!newModuleName) return;
    try {
      await apiFetch(`/api/courses/${courseId}/modules`, {
        method: 'POST',
        body: JSON.stringify({ title: newModuleName, order: (course?.modules?.length || 0) + 1 })
      });
      setNewModuleName('');
      fetchCourseDetails();
    } catch (e: any) {
      alert(e.message || 'Failed to add module');
    }
  };

  // Add Lesson with S3 upload (Instructor only)
  const handleAddLesson = async (moduleId: number) => {
    if (!newLessonTitle) return;
    setUploading(true);
    try {
      let contentUrl = '';
      if (newLessonType === 'video' && selectedFile) {
        // 1. Upload file to content-service
        const formData = new FormData();
        formData.append('file', selectedFile);
        const uploadRes = await apiFetch('/api/content/upload', {
          method: 'POST',
          body: formData
        });
        contentUrl = uploadRes.id.toString(); // Save the media ID
      } else if (newLessonType === 'quiz') {
        // Create a mock quiz for this lesson
        const quizRes = await apiFetch('/api/quizzes/', {
          method: 'POST',
          body: JSON.stringify({ course_id: parseInt(courseId!), title: `Quiz: ${newLessonTitle}`, passing_score: 70 })
        });
        
        // Add a mock question to the quiz
        await apiFetch(`/api/quizzes/${quizRes.id}/questions`, {
          method: 'POST',
          body: JSON.stringify({
            question_text: "Which architectural pattern is used in EduSphere?",
            question_type: "multiple_choice",
            options: [
              { option_text: "Monolithic", is_correct: false },
              { option_text: "Microservices", is_correct: true },
              { option_text: "Serverless", is_correct: false }
            ]
          })
        });
        contentUrl = quizRes.id.toString();
      }

      // 2. Add Lesson
      await apiFetch(`/api/courses/modules/${moduleId}/lessons`, {
        method: 'POST',
        body: JSON.stringify({
          title: newLessonTitle,
          content_type: newLessonType,
          content_url: contentUrl,
          order: 1
        })
      });

      setNewLessonTitle('');
      setSelectedFile(null);
      fetchCourseDetails();
    } catch (e: any) {
      alert(e.message || 'Failed to add lesson');
    } finally {
      setUploading(false);
    }
  };

  // Quiz submission
  const handleQuizSubmit = async () => {
    if (!quiz) return;
    const answers = Object.keys(selectedAnswers).map(qId => ({
      question_id: parseInt(qId),
      selected_option_id: selectedAnswers[parseInt(qId)]
    }));

    try {
      const res = await apiFetch(`/api/quizzes/${quiz.id}/submit`, {
        method: 'POST',
        body: JSON.stringify({ answers })
      });
      setQuizResult(res);
      setQuizSubmitted(true);
    } catch (e: any) {
      alert(e.message || 'Submission failed');
    }
  };

  // Publish course (Instructor only)
  const handlePublishCourse = async () => {
    try {
      await apiFetch(`/api/courses/${courseId}`, {
        method: 'PUT',
        body: JSON.stringify({ is_published: true })
      });
      alert('Course published successfully!');
      fetchCourseDetails();
    } catch (e: any) {
      alert(e.message || 'Failed to publish');
    }
  };

  if (loading) return <Layout><div className="text-center">Loading Course...</div></Layout>;

  const isInstructor = user?.role === 'instructor' && course?.instructor_id === user?.id;

  return (
    <Layout>
      <div className="flex flex-col lg:flex-row gap-8">
        
        {/* Left Tree Navigator */}
        <div className="w-full lg:w-80 shrink-0 flex flex-col gap-6">
          <div className="glass-panel rounded-2xl p-6 shadow-sm">
            <h2 className="font-bold text-lg leading-tight">{course?.title}</h2>
            <p className="text-slate-500 text-xs mt-1">Instructor ID: {course?.instructor_id}</p>
            
            {isInstructor && !course?.is_published && (
              <button 
                onClick={handlePublishCourse}
                className="mt-4 w-full rounded-xl bg-green-600 py-2.5 text-xs font-bold text-white hover:bg-green-500 shadow-lg shadow-green-600/20"
              >
                Publish Course
              </button>
            )}
          </div>

          {/* Module list */}
          <div className="flex flex-col gap-4">
            <h3 className="font-semibold text-sm uppercase tracking-wider text-slate-400">Course Syllabus</h3>
            
            {course?.modules?.map((mod: any) => (
              <div key={mod.id} className="glass-panel rounded-xl p-4 flex flex-col gap-2">
                <span className="text-xs font-semibold text-indigo-500">Module {mod.order}</span>
                <h4 className="font-bold text-sm leading-snug">{mod.title}</h4>
                <div className="flex flex-col gap-1.5 mt-3 border-t border-slate-150 dark:border-slate-800 pt-3">
                  {mod.lessons?.map((les: any) => (
                    <button
                      key={les.id}
                      onClick={() => handleSelectLesson(les)}
                      className={`flex items-center gap-2 text-left text-xs p-2 rounded-lg transition-colors ${activeLesson?.id === les.id ? 'bg-indigo-600 text-white font-semibold' : 'hover:bg-slate-100 dark:hover:bg-slate-800'}`}
                    >
                      {les.content_type === 'video' ? <Play className="h-3.5 w-3.5" /> : <FileText className="h-3.5 w-3.5" />}
                      <span className="truncate">{les.title}</span>
                    </button>
                  ))}

                  {isInstructor && (
                    <div className="mt-4 flex flex-col gap-2 bg-slate-100/50 dark:bg-slate-900/50 p-3 rounded-lg border border-slate-200 dark:border-slate-800">
                      <span className="text-[10px] font-bold text-slate-400">Add Lesson</span>
                      <input 
                        type="text" 
                        placeholder="Lesson Title" 
                        value={newLessonTitle}
                        onChange={e => setNewLessonTitle(e.target.value)}
                        className="w-full rounded-md border border-slate-200 dark:border-slate-800 bg-transparent px-2 py-1 text-xs"
                      />
                      <select 
                        value={newLessonType} 
                        onChange={e => setNewLessonType(e.target.value)}
                        className="w-full rounded-md border border-slate-200 dark:border-slate-800 bg-slate-100 dark:bg-slate-900 px-2 py-1 text-xs text-white"
                      >
                        <option value="video">Video (MP4)</option>
                        <option value="quiz">Quiz</option>
                      </select>
                      {newLessonType === 'video' && (
                        <input 
                          type="file" 
                          accept="video/mp4" 
                          onChange={e => setSelectedFile(e.target.files?.[0] || null)}
                          className="w-full text-[10px] text-slate-500"
                        />
                      )}
                      <button 
                        onClick={() => handleAddLesson(mod.id)} 
                        disabled={uploading}
                        className="w-full rounded bg-indigo-600 py-1 text-[10px] font-bold text-white hover:bg-indigo-500"
                      >
                        {uploading ? 'Uploading...' : 'Save Lesson'}
                      </button>
                    </div>
                  )}
                </div>
              </div>
            ))}

            {isInstructor && (
              <div className="glass-panel rounded-xl p-4 flex flex-col gap-2">
                <span className="text-xs font-semibold text-indigo-500">Create Module</span>
                <input 
                  type="text" 
                  placeholder="Module Title" 
                  value={newModuleName}
                  onChange={e => setNewModuleName(e.target.value)}
                  className="w-full rounded-lg border border-slate-200 dark:border-slate-800 bg-transparent px-3 py-2 text-xs"
                />
                <button onClick={handleAddModule} className="w-full rounded-lg bg-indigo-600 py-2 text-xs font-bold text-white hover:bg-indigo-500">
                  Add Module
                </button>
              </div>
            )}
          </div>
        </div>

        {/* Right Player Panel */}
        <div className="flex-1 flex flex-col gap-6">
          {activeLesson ? (
            <div className="glass-panel rounded-2xl p-6 shadow-sm">
              <h2 className="text-xl font-bold mb-4">{activeLesson.title}</h2>
              
              {activeLesson.content_type === 'video' && videoUrl && (
                <div className="overflow-hidden rounded-xl bg-black aspect-video">
                  <video key={videoUrl} controls className="w-full h-full">
                    <source src={videoUrl} type="video/mp4" />
                    Your browser does not support the video tag.
                  </video>
                </div>
              )}

              {activeLesson.content_type === 'quiz' && quiz && (
                <div className="flex flex-col gap-6">
                  <div className="border-b border-slate-150 dark:border-slate-800 pb-4">
                    <h3 className="text-lg font-bold">{quiz.title}</h3>
                    <p className="text-xs text-slate-500 mt-1">Passing score: {quiz.passing_score}%</p>
                  </div>
                  
                  {!quizSubmitted ? (
                    <div className="flex flex-col gap-6">
                      {quiz.questions?.map((q: any) => (
                        <div key={q.id} className="flex flex-col gap-3">
                          <p className="text-sm font-semibold">{q.question_text}</p>
                          <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
                            {q.options?.map((opt: any) => (
                              <button
                                key={opt.id}
                                onClick={() => setSelectedAnswers({ ...selectedAnswers, [q.id]: opt.id })}
                                className={`rounded-xl border p-4 text-left text-xs transition-all ${selectedAnswers[q.id] === opt.id ? 'border-indigo-600 bg-indigo-600/10' : 'border-slate-200 dark:border-slate-800 hover:bg-slate-50 dark:hover:bg-slate-800/50'}`}
                              >
                                {opt.option_text}
                              </button>
                            ))}
                          </div>
                        </div>
                      ))}
                      <button 
                        onClick={handleQuizSubmit}
                        className="rounded-xl bg-indigo-600 py-3 text-sm font-semibold text-white hover:bg-indigo-500 mt-4 shadow-lg shadow-indigo-600/20"
                      >
                        Submit Quiz
                      </button>
                    </div>
                  ) : (
                    <div className="text-center py-12 flex flex-col items-center">
                      {quizResult?.passed ? (
                        <>
                          <Award className="h-16 w-16 text-amber-500 mb-4 animate-bounce" />
                          <h4 className="text-2xl font-extrabold text-gradient">Congratulations! You Passed!</h4>
                          <p className="text-sm text-slate-500 mt-2">Your score: {quizResult.score}% (Passing score: {quiz.passing_score}%)</p>
                          <p className="text-xs text-green-500 mt-4">A completion certificate has been added to your profile.</p>
                        </>
                      ) : (
                        <>
                          <ShieldAlert className="h-16 w-16 text-red-500 mb-4" />
                          <h4 className="text-2xl font-extrabold text-red-500">Quiz Failed</h4>
                          <p className="text-sm text-slate-500 mt-2">Your score: {quizResult?.score}% (Passing score: {quiz.passing_score}%)</p>
                          <button onClick={() => { setQuizSubmitted(false); setQuizResult(null); setSelectedAnswers({}); }} className="mt-6 rounded-xl bg-indigo-600 px-6 py-2.5 text-xs font-semibold text-white">
                            Try Again
                          </button>
                        </>
                      )}
                    </div>
                  )}
                </div>
              )}
            </div>
          ) : (
            <div className="glass-panel rounded-2xl p-12 text-center shadow-sm">
              <p className="text-slate-500 text-sm">Select a lesson from the syllabus to begin learning.</p>
            </div>
          )}
        </div>
      </div>
    </Layout>
  );
}

// ==========================================
// 8. PROFILE & SETTINGS PAGE
// ==========================================

function ProfilePage() {
  const { user, apiFetch } = useAuth();
  const [fullName, setFullName] = useState(user?.full_name || '');
  const [email, setEmail] = useState(user?.email || '');
  
  const [oldPassword, setOldPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  const handleUpdateProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage('');
    setError('');
    try {
      await apiFetch('/auth/me', {
        method: 'PUT',
        body: JSON.stringify({ full_name: fullName, email })
      });
      setMessage('Profile updated successfully!');
    } catch (err: any) {
      setError(err.message || 'Failed to update profile');
    }
  };

  const handleChangePassword = async (e: React.FormEvent) => {
    e.preventDefault();
    setMessage('');
    setError('');
    try {
      await apiFetch('/auth/change-password', {
        method: 'POST',
        body: JSON.stringify({ old_password: oldPassword, new_password: newPassword })
      });
      setMessage('Password changed successfully!');
      setOldPassword('');
      setNewPassword('');
    } catch (err: any) {
      setError(err.message || 'Failed to change password');
    }
  };

  return (
    <Layout>
      <div className="max-w-4xl mx-auto flex flex-col gap-8">
        <div>
          <h1 className="text-3xl font-extrabold">Profile & Settings</h1>
          <p className="text-slate-500 text-sm mt-1">Manage your account details and security preferences.</p>
        </div>

        {message && <div className="rounded-xl bg-green-500/10 border border-green-500/20 p-4 text-sm text-green-500">{message}</div>}
        {error && <div className="rounded-xl bg-red-500/10 border border-red-500/20 p-4 text-sm text-red-500">{error}</div>}

        <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
          {/* Profile Form */}
          <div className="glass-panel rounded-2xl p-6 shadow-sm">
            <h2 className="text-lg font-bold mb-4 flex items-center gap-2">
              <User className="h-5 w-5 text-indigo-500" /> Personal Details
            </h2>
            <form onSubmit={handleUpdateProfile} className="flex flex-col gap-4">
              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Full Name</label>
                <input 
                  type="text" 
                  value={fullName}
                  onChange={e => setFullName(e.target.value)}
                  className="w-full rounded-xl border border-slate-200 dark:border-slate-800 bg-transparent px-4 py-3 text-sm focus:border-indigo-500 focus:outline-none"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Email Address</label>
                <input 
                  type="email" 
                  value={email}
                  onChange={e => setEmail(e.target.value)}
                  className="w-full rounded-xl border border-slate-200 dark:border-slate-800 bg-transparent px-4 py-3 text-sm focus:border-indigo-500 focus:outline-none"
                />
              </div>
              <button type="submit" className="rounded-xl bg-indigo-600 py-3 text-sm font-semibold text-white hover:bg-indigo-500">
                Save Changes
              </button>
            </form>
          </div>

          {/* Password Form */}
          <div className="glass-panel rounded-2xl p-6 shadow-sm">
            <h2 className="text-lg font-bold mb-4 flex items-center gap-2">
              <Lock className="h-5 w-5 text-indigo-500" /> Security
            </h2>
            <form onSubmit={handleChangePassword} className="flex flex-col gap-4">
              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">Current Password</label>
                <input 
                  type="password" 
                  value={oldPassword}
                  onChange={e => setOldPassword(e.target.value)}
                  className="w-full rounded-xl border border-slate-200 dark:border-slate-800 bg-transparent px-4 py-3 text-sm focus:border-indigo-500 focus:outline-none"
                  placeholder="••••••••"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold uppercase tracking-wider text-slate-400 mb-1.5">New Password</label>
                <input 
                  type="password" 
                  value={newPassword}
                  onChange={e => setNewPassword(e.target.value)}
                  className="w-full rounded-xl border border-slate-200 dark:border-slate-800 bg-transparent px-4 py-3 text-sm focus:border-indigo-500 focus:outline-none"
                  placeholder="••••••••"
                />
              </div>
              <button type="submit" className="rounded-xl bg-indigo-600 py-3 text-sm font-semibold text-white hover:bg-indigo-500">
                Change Password
              </button>
            </form>
          </div>
        </div>
      </div>
    </Layout>
  );
}
