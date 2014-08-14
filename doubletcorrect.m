function [trueA trueB] = doubletcorrect(A,B,D)
trueA = ((A+D).*(B+D)-D./2)./(B+D./2);
trueB = ((A+D).*(B+D)-D./2)./(A+D./2);