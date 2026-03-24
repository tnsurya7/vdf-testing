import { useState } from "react";
import { Link } from "react-router-dom";
import { z } from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Form, FormControl, FormField, FormItem, FormLabel, FormMessage } from "@/components/ui/form";
import { toast } from "@/hooks/use-toast";
import PublicLayout from "@/components/layout/PublicLayout";

const schema = z.object({
  email: z.string().email("Please enter a valid email address"),
});

type FormValues = z.infer<typeof schema>;

const ForgotPassword = () => {
  const [submitted, setSubmitted] = useState(false);

  const form = useForm<FormValues>({
    resolver: zodResolver(schema),
    defaultValues: { email: "" },
  });

  async function onSubmit(data: FormValues) {
    try {
      await fetch(`${import.meta.env.VITE_API_BASE_URL ?? ""}/auth/forgot-password`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ email: data.email }),
      });
      // Always show success to avoid email enumeration
      setSubmitted(true);
    } catch {
      toast({ title: "Error", description: "Something went wrong. Please try again.", variant: "destructive" });
    }
  }

  return (
    <PublicLayout subtitle="Forgot Password" backTo="/login" backLabel="Sign In">
      <main className="flex-1 flex items-center justify-center px-4 py-12">
        <div className="w-full max-w-md">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-foreground uppercase tracking-wide">Forgot Password</h1>
            <p className="text-sm text-muted-foreground mt-1">Enter your registered email to receive a password reset link</p>
          </div>

          <div className="bg-card border border-border p-8">
            {submitted ? (
              <div className="text-center space-y-4">
                <p className="text-sm text-foreground">
                  If an account exists for that email, a password reset link has been sent.
                </p>
                <Link to="/login" className="text-primary font-semibold hover:underline text-sm">
                  Back to Sign In
                </Link>
              </div>
            ) : (
              <Form {...form}>
                <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-5">
                  <FormField control={form.control} name="email" render={({ field }) => (
                    <FormItem>
                      <FormLabel className="text-foreground font-semibold text-sm uppercase tracking-wide">
                        Email ID <span className="text-destructive">*</span>
                      </FormLabel>
                      <FormControl>
                        <Input placeholder="you@company.com" className="h-11 border-border" {...field} />
                      </FormControl>
                      <FormMessage />
                    </FormItem>
                  )} />
                  <Button type="submit" size="lg" className="w-full h-11 font-bold uppercase tracking-wider">
                    Send Reset Link
                  </Button>
                </form>
              </Form>
            )}
          </div>

          <p className="text-sm text-muted-foreground text-center mt-6">
            Remembered your password?{" "}
            <Link to="/login" className="text-primary font-semibold hover:underline">Sign In</Link>
          </p>
        </div>
      </main>
    </PublicLayout>
  );
};

export default ForgotPassword;
