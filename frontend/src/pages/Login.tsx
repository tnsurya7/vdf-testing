import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { Eye, EyeOff } from "lucide-react";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { Input } from "@/components/ui/input";
import { setSession, setToken } from "@/lib/authStore";
import { useLoginMutation, type LoginResponse } from "@/store/api";
import PublicLayout from "@/components/layout/PublicLayout";

const loginSchema = z.object({
  email: z.string().email("Please enter a valid email address").max(250, "Max 250 characters"),
  password: z.string().min(1, "Password is required").max(250, "Max 250 characters")
});

type LoginFormValues = z.infer<typeof loginSchema>;

const Login = () => {
  const [showPassword, setShowPassword] = useState(false);
  const navigate = useNavigate();
  const [login, { isLoading: isLoginLoading }] = useLoginMutation();

  const form = useForm<LoginFormValues>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: "", password: "" }
  });

  function applyLoginResponse(res: LoginResponse) {
    setToken(res.accessToken);
    setSession(res.user);
  }

  async function onSubmit(data: LoginFormValues) {
    try {
      const res = await login({ email: data.email, password: data.password }).unwrap();
      applyLoginResponse(res);
      const roles = res.user.roles ?? [];
      if (roles.includes("admin")) navigate("/admin/registrations");
      else if (roles.length === 0) navigate("/applicant/dashboard");
      else navigate("/sidbi/dashboard");
    } catch {
      form.setError("email", { message: "Invalid email or password" });
    }
  }

  return (
    <PublicLayout subtitle="Venture Debt Fund" backTo="/" backLabel="Home">
      <main className="flex-1 flex items-center justify-center px-4 py-12">
        <div className="w-full max-w-md">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-foreground uppercase tracking-wide">Sign In</h1>
            <p className="text-sm text-muted-foreground mt-1">Access your Venture Debt Fund portal</p>
          </div>

          <div className="bg-card border border-border p-8 space-y-6">
            <Form {...form}>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-5">
                <FormField control={form.control} name="email" render={({ field }) =>
                  <FormItem>
                    <FormLabel className="text-foreground font-semibold text-sm uppercase tracking-wide">Email ID <span className="text-destructive">*</span></FormLabel>
                    <FormControl>
                      <Input placeholder="you@company.com" className="h-11 border-border" {...field} />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                } />

                <FormField control={form.control} name="password" render={({ field }) =>
                  <FormItem>
                    <FormLabel className="text-foreground font-semibold text-sm uppercase tracking-wide">Password <span className="text-destructive">*</span></FormLabel>
                    <FormControl>
                      <div className="relative">
                        <Input type={showPassword ? "text" : "password"} placeholder="Enter your password" className="h-11 border-border" {...field} />
                        <Button type="button" variant="ghost" size="icon"
                          className="absolute right-1 top-1/2 -translate-y-1/2 h-8 w-8 text-muted-foreground"
                          onClick={() => setShowPassword(!showPassword)}>
                          {showPassword ? <EyeOff className="h-4 w-4" /> : <Eye className="h-4 w-4" />}
                        </Button>
                      </div>
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                } />

                <Button type="submit" size="lg" className="w-full h-11 font-bold uppercase tracking-wider" disabled={isLoginLoading}>
                  {isLoginLoading ? "Signing In…" : "Sign In"}
                </Button>
                <div className="text-right">
                  <Link to="/forgot-password" className="text-xs text-muted-foreground hover:text-primary hover:underline">
                    Forgot Password?
                  </Link>
                </div>
              </form>
            </Form>
          </div>

          <p className="text-sm text-muted-foreground text-center mt-6">
            Don't have an account?{" "}
            <Link to="/register" className="text-primary font-semibold hover:underline">Register</Link>
          </p>
        </div>
      </main>
    </PublicLayout>
  );
};

export default Login;
