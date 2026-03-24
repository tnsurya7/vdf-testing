import { useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { useSetPasswordMutation } from "@/store/api";
import { toast } from "@/hooks/use-toast";
import { Eye, EyeOff, KeyRound } from "lucide-react";

const SetPassword = () => {
  const { token } = useParams<{ token: string }>();
  const navigate = useNavigate();
  const [setPassword, { isLoading }] = useSetPasswordMutation();

  const [password, setPasswordVal]   = useState("");
  const [confirm, setConfirm]        = useState("");
  const [showPwd, setShowPwd]        = useState(false);
  const [showConfirm, setShowConfirm] = useState(false);
  const [done, setDone]              = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (password.length < 8) {
      toast({ title: "Validation Error", description: "Password must be at least 8 characters.", variant: "destructive" });
      return;
    }
    if (password !== confirm) {
      toast({ title: "Validation Error", description: "Passwords do not match.", variant: "destructive" });
      return;
    }
    if (!token) {
      toast({ title: "Error", description: "Invalid setup link.", variant: "destructive" });
      return;
    }
    try {
      await setPassword({ token, password }).unwrap();
      setDone(true);
      toast({ title: "Password Set", description: "Your password has been set. You can now log in." });
    } catch {
      toast({ title: "Error", description: "Invalid or expired setup link. Please contact your administrator.", variant: "destructive" });
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-background p-4">
      <div className="w-full max-w-sm bg-card border border-border p-8 space-y-6">
        <div className="flex flex-col items-center gap-2">
          <KeyRound className="h-8 w-8 text-primary" />
          <h1 className="text-xl font-bold uppercase tracking-wider text-foreground">Set Your Password</h1>
          <p className="text-xs text-muted-foreground text-center">Venture Debt Fund — SIDBI</p>
        </div>

        {done ? (
          <div className="space-y-4 text-center">
            <p className="text-sm text-foreground">Your password has been set successfully.</p>
            <Button className="w-full font-bold uppercase tracking-wider" onClick={() => navigate("/login")}>
              Go to Login
            </Button>
          </div>
        ) : (
          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="space-y-1.5">
              <Label className="text-xs font-semibold uppercase tracking-wide">New Password <span className="text-destructive">*</span></Label>
              <div className="relative">
                <Input
                  type={showPwd ? "text" : "password"}
                  placeholder="Min 8 characters"
                  value={password}
                  onChange={(e) => setPasswordVal(e.target.value)}
                  className="h-9 pr-9"
                  required
                />
                <Button type="button" variant="ghost" size="icon"
                  className="absolute right-1 top-1/2 -translate-y-1/2 h-7 w-7 text-muted-foreground"
                  onClick={() => setShowPwd(!showPwd)}>
                  {showPwd ? <EyeOff className="h-3.5 w-3.5" /> : <Eye className="h-3.5 w-3.5" />}
                </Button>
              </div>
            </div>
            <div className="space-y-1.5">
              <Label className="text-xs font-semibold uppercase tracking-wide">Confirm Password <span className="text-destructive">*</span></Label>
              <div className="relative">
                <Input
                  type={showConfirm ? "text" : "password"}
                  placeholder="Repeat password"
                  value={confirm}
                  onChange={(e) => setConfirm(e.target.value)}
                  className="h-9 pr-9"
                  required
                />
                <Button type="button" variant="ghost" size="icon"
                  className="absolute right-1 top-1/2 -translate-y-1/2 h-7 w-7 text-muted-foreground"
                  onClick={() => setShowConfirm(!showConfirm)}>
                  {showConfirm ? <EyeOff className="h-3.5 w-3.5" /> : <Eye className="h-3.5 w-3.5" />}
                </Button>
              </div>
            </div>
            <Button type="submit" className="w-full font-bold uppercase tracking-wider" disabled={isLoading}>
              {isLoading ? "Setting Password…" : "Set Password"}
            </Button>
          </form>
        )}
      </div>
    </div>
  );
};

export default SetPassword;
